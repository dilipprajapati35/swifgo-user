import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class DateTimePickerModal {
  // State variables for the modal
  DateTime _selectedDate = DateTime.now();
  int _selectedHour = DateTime.now().hour % 12 == 0
      ? 12
      : DateTime.now().hour % 12; // 1-12 format
  int _selectedMinute = DateTime.now().minute;
  String _selectedAmPm = DateTime.now().hour >= 12 ? "PM" : "AM";

  // Scroll controllers for ListWheelScrollView
  late FixedExtentScrollController _dateController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  // Data for the pickers
  List<DateTime> _dateOptions = [];
  List<String> _dateDisplayStrings = [];
  double _swipeIconHorizontalOffset = 0.0;
  bool _isSwipeCompleted = false;
  void _initializePickers() {
    _swipeIconHorizontalOffset = 0.0; // Reset swipe state
    _isSwipeCompleted = false;
    _selectedDate = DateTime.now(); // Reset to current date
    _selectedHour =
        DateTime.now().hour % 12 == 0 ? 12 : DateTime.now().hour % 12;
    _selectedMinute = DateTime.now().minute;
    _selectedAmPm = DateTime.now().hour >= 12 ? "PM" : "AM";

    // Generate date options (e.g., 7 days past, today, 60 days future)
    _dateOptions = [];
    _dateDisplayStrings = [];
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (int i = -7; i < 60; i++) {
      // Range: 7 days ago to 59 days from now
      DateTime date = today.add(Duration(days: i));
      _dateOptions.add(date);
      if (i == 0) {
        _dateDisplayStrings.add("Today");
      } else if (i == 1) {
        _dateDisplayStrings.add("Tomorrow");
      } else if (i == -1) {
        _dateDisplayStrings.add("Yesterday");
      } else {
        _dateDisplayStrings.add(DateFormat('EEE, MMM d').format(date));
      }
    }

    int initialDateIndex = _dateOptions.indexWhere((d) =>
        d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day);
    if (initialDateIndex == -1)
      initialDateIndex = 7; // Default to today if something goes wrong

    _dateController =
        FixedExtentScrollController(initialItem: initialDateIndex);
    _hourController = FixedExtentScrollController(
        initialItem: _selectedHour - 1); // 0-11 index for 1-12 hours
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
    _amPmController =
        FixedExtentScrollController(initialItem: _selectedAmPm == "AM" ? 0 : 1);
  }

  String _getFormattedPickupTime() {
    int hour24 = _selectedAmPm == "PM"
        ? (_selectedHour == 12 ? 12 : _selectedHour + 12)
        : (_selectedHour == 12 ? 0 : _selectedHour); // 12 AM is 0 hour

    final DateTime fullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour24,
      _selectedMinute,
    );
    return DateFormat('dd MMM yyyy, hh:mm a').format(fullDateTime);
  }

  void show(BuildContext pageContext,
      {required Function(DateTime date, String timePeriod) onSelectDateTime}) {
    _initializePickers(); // Initialize/reset pickers every time modal is shown

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final List<String> hours = List.generate(
                12, (index) => (index + 1).toString().padLeft(2, '0'));
            final List<String> minutes =
                List.generate(60, (index) => index.toString().padLeft(2, '0'));
            final List<String> amPm = ["AM", "PM"];

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 75), // Space for close button
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                    decoration: const BoxDecoration(
                      color: AppColor.greyWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "When do you need driver?",
                          style: AppStyle.title3.copyWith(
                              fontSize: 22, color: AppColor.greyShade1),
                        ),
                        8.height,
                        Text(
                          "Pickup Time: ${_getFormattedPickupTime()}",
                          style: AppStyle.subheading.copyWith(
                              color: AppColor.greyShade2, fontSize: 14),
                        ),
                        20.height,
                        // Removed _buildDatePicker here, it's integrated into _buildDateTimePickerWheels
                        _buildDateTimePickerWheels(
                            hours, minutes, amPm, setModalState),
                        30.height,
                        _buildSwipeButton(modalContext, onSelectDateTime, setModalState),
                        10.height,
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: InkWell(
                      onTap: () => Navigator.pop(modalContext),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColor.greyShade1,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2))
                            ]),
                        child: const Icon(Icons.close,
                            color: AppColor.greyWhite, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimePickerWheels(List<String> hours, List<String> minutes,
      List<String> amPm, StateSetter setModalState) {
    const double itemExtent = 40.0;
    const double selectedFontSize = 18.0; // Adjusted for more wheels
    const double unselectedFontSize = 14.0; // Adjusted

    TextStyle selectedStyle = AppStyle.title.copyWith(
        fontSize: selectedFontSize,
        color: AppColor.greyShade1,
        fontWeight: FontWeight.bold);
    TextStyle unselectedStyle = AppStyle.body.copyWith(
        fontSize: unselectedFontSize,
        color: AppColor.greyShade3.withOpacity(0.7));

    Widget pickerWheel(
      FixedExtentScrollController controller,
      List<String> items, // Display strings
      Function(int) onSelectedItemChanged, {
      bool isDateWheel = false,
    }) {
      return Expanded(
        flex: isDateWheel ? 2 : 1, // Give date wheel more space if needed
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          perspective: 0.005,
          squeeze: 1.0,
          childDelegate: ListWheelChildLoopingListDelegate(
            // Can be non-looping for date if preferred
            children: items.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final itemString = entry.value;
              bool isSelectedCurrentWheelItem = false;

              if (isDateWheel) {
                DateTime currentDateInWheel = _dateOptions[
                    index % _dateOptions.length]; // Handle looping index
                isSelectedCurrentWheelItem =
                    currentDateInWheel.year == _selectedDate.year &&
                        currentDateInWheel.month == _selectedDate.month &&
                        currentDateInWheel.day == _selectedDate.day;
              } else if (items == hours) {
                isSelectedCurrentWheelItem =
                    (int.parse(itemString)) == _selectedHour;
              } else if (items == minutes) {
                isSelectedCurrentWheelItem =
                    (int.parse(itemString)) == _selectedMinute;
              } else if (items == amPm) {
                isSelectedCurrentWheelItem = (itemString) == _selectedAmPm;
              }

              return Center(
                child: Text(
                  itemString,
                  style: isSelectedCurrentWheelItem
                      ? selectedStyle
                      : unselectedStyle,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Container(
      height: 150, // Keep or adjust height as needed
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              pickerWheel(_dateController, _dateDisplayStrings, (index) {
                setModalState(() {
                  _selectedDate = _dateOptions[index];
                });
              }, isDateWheel: true),
              pickerWheel(_hourController, hours, (index) {
                setModalState(() {
                  _selectedHour = int.parse(hours[index]);
                });
              }),
              pickerWheel(_minuteController, minutes, (index) {
                setModalState(() {
                  _selectedMinute = int.parse(minutes[index]);
                });
              }),
              pickerWheel(_amPmController, amPm, (index) {
                setModalState(() {
                  _selectedAmPm = amPm[index];
                });
              }),
            ],
          ),
          Positioned(
            top: (150 / 2) - (itemExtent / 2) - 1,
            left: 10,
            right: 10,
            child: Divider(color: AppColor.greyShade5, thickness: 1),
          ),
          Positioned(
            bottom: (150 / 2) - (itemExtent / 2) - 1,
            left: 10,
            right: 10,
            child: Divider(color: AppColor.greyShade5, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButton(BuildContext modalContext,
      Function(DateTime date, String timePeriod) onSelectDateTime, StateSetter setModalState) {
    const double iconBoxSize = 48.0; // Size of the draggable white box
    const double iconBoxMargin = 6.0; // Margin around the white box
    const double effectiveIconSize = iconBoxSize +
        (iconBoxMargin * 2); // Total space icon box takes initially

    return LayoutBuilder(
      // Use LayoutBuilder to get constraints for swipe track width
      builder: (context, constraints) {
        // Calculate the maximum swipe distance.
        // The icon should stop before completely leaving the blue button.
        final double maxSwipeDistance = constraints.maxWidth -
            effectiveIconSize -
            (iconBoxMargin * 2); // Leave some padding on right

        return Container(
          // The main blue button track
          height: 54,
          decoration: BoxDecoration(
            color: AppColor.buttonColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColor.greyShade2,
                spreadRadius: 0,
                blurRadius: 3,
                offset: Offset(0, -3),
                inset: true,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Text "Swipe right to select seat" - positioned centrally
              Positioned.fill(
                left: effectiveIconSize -
                    20, // Adjust left padding to not overlap with initial icon too much
                right: 20, // Padding on the right
                child: Center(
                  child: Text(
                    "Swipe right to select seat",
                    style: AppStyle.body.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // The Draggable Icon
              AnimatedPositioned(
                duration: _isSwipeCompleted
                    ? const Duration(milliseconds: 100)
                    : const Duration(
                        milliseconds: 0), // Quick snap back if not completed
                left: iconBoxMargin + _swipeIconHorizontalOffset,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    if (_isSwipeCompleted)
                      return; // Don't allow drag if already completed
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isSwipeCompleted) return;
                    setModalState(() {
                      _swipeIconHorizontalOffset += details.delta.dx;
                      // Clamp the offset
                      if (_swipeIconHorizontalOffset < 0) {
                        _swipeIconHorizontalOffset = 0;
                      }
                      if (_swipeIconHorizontalOffset > maxSwipeDistance) {
                        _swipeIconHorizontalOffset = maxSwipeDistance;
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isSwipeCompleted) return;
                    setModalState(() {
                      final double swipeThreshold = maxSwipeDistance * 0.7;
                      if (_swipeIconHorizontalOffset >= swipeThreshold) {
                        _isSwipeCompleted = true;
                        _swipeIconHorizontalOffset = maxSwipeDistance;

                        int hour24 = _selectedAmPm == "PM"
                            ? (_selectedHour == 12 ? 12 : _selectedHour + 12)
                            : (_selectedHour == 12 ? 0 : _selectedHour);
                        final DateTime finalSelectedDateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            hour24,
                            _selectedMinute);

                        Navigator.pop(modalContext);
                        onSelectDateTime(finalSelectedDateTime, _selectedAmPm);
                      } else {
                        _swipeIconHorizontalOffset = 0;
                      }
                    });
                  },
                  child: Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                        color: AppColor.greyWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          // Optional: Add a slight shadow to the draggable part
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(1, 1))
                        ]),
                    child: const Center(
                      child: Icon(Icons.double_arrow_rounded,
                          color: AppColor.buttonColor, size: 28),
                    ),
                  ),
                ),
              ),

              // Optional: Trailing arrow hint (static)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(Icons.arrow_forward_ios,
                      color: AppColor.greyWhite.withOpacity(0.5), size: 16),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
