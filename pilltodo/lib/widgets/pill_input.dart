import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PillInputForm extends StatefulWidget {
  const PillInputForm({Key? key}) : super(key: key);

  @override
  _PillInputFormState createState() => _PillInputFormState();
}

class _PillInputFormState extends State<PillInputForm> {
  late DateTime _startDate;
  late DateTime _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now()
        .add(Duration(days: 7)); // Default end date: 7 days from now
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Customer Contact', textAlign: TextAlign.left),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: ElevatedButton(
            onPressed: _selectDateRange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: [
                const Icon(Icons.calendar_month), // 아이콘 추가
                const SizedBox(width: 5), // 아이콘과 텍스트 사이의 간격 조정
                Text(
                  '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                  style: const TextStyle(fontSize: 16), // 텍스트 스타일 조정 가능
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
