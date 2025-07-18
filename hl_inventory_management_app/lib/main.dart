import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox('inventory');
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Forecast',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddDataScreen()),
              ),
              child: Text('Add Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PredictScreen()),
              ),
              child: Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _box = Hive.box('inventory');
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  final Map<String, double> _data = {};
  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _data.clear();
    for (var key in _box.keys) {
      if (_box.get(key) is Map) {
        final Map record = _box.get(key);
        if (record['year'] == _selectedYear &&
            record['month'] == _selectedMonth) {
          _data[record['item']] = record['ordered'];
        }
      }
    }
  }

  void _saveData() {
    for (var entry in _data.entries) {
      final record = {
        'year': _selectedYear,
        'month': _selectedMonth,
        'item': entry.key,
        'ordered': entry.value,
      };
      _box.add(record);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Inventory Data')),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(_selectedYear, _selectedMonth),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedYear = picked.year;
                            _selectedMonth = picked.month;
                            if (mounted) _loadExistingData();
                          });
                        }
                      },
                      child: Text('Select Month/Year'),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "${_selectedMonth.toString().padLeft(2, '0')} / $_selectedYear",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('${m.toString().padLeft(2, '0')}'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _data.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: entry.value.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            _data[entry.key] = double.tryParse(val) ?? 0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: InputDecoration(labelText: 'New Product'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _newItemController.text;
                    if (name.isNotEmpty && !_data.containsKey(name)) {
                      setState(() {
                        _data[name] = 0;
                        _newItemController.clear();
                      });
                    }
                  },
                  child: Text('Add Product'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _saveData, child: Text('Save All')),
          ],
        ),
      ),
    );
  }
}

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _box = Hive.box('inventory');
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  final _itemController = TextEditingController();
  String? _result;

  double? _predict(String item, int month) {
    List<double> values = [];
    for (var record in _box.values) {
      if (record is Map &&
          record['item'] == item &&
          record['month'] == month &&
          record['year'] != _selectedYear) {
        values.add(record['ordered']);
      }
    }
    if (values.length >= 1) {
      final average = values.reduce((a, b) => a + b) / values.length;
      return average;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Predict Inventory')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(_selectedYear, _selectedMonth),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedYear = picked.year;
                        _selectedMonth = picked.month;
                      });
                    }
                  },
                  child: Text('Select Month/Year'),
                ),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('${m.toString().padLeft(2, '0')}'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ],
            ),
            TextField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final prediction = _predict(
                  _itemController.text,
                  _selectedMonth,
                );
                setState(() {
                  _result = prediction != null
                      ? 'Predicted order for ${_itemController.text}: ${prediction.toStringAsFixed(1)}'
                      : 'Not enough data to predict.';
                });
              },
              child: Text('Generate Prediction'),
            ),
            SizedBox(height: 20),
            if (_result != null)
              Text(
                _result!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
