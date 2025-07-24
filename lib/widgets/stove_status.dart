import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class StoveStatus extends StatefulWidget {
  const StoveStatus({super.key});

  @override
  State<StoveStatus> createState() => _StoveStatusState();
}

class _StoveStatusState extends State<StoveStatus> {
  bool _leftStoveOn = false;
  bool _rightStoveOn = false;
  int _leftStoveSeconds = 0;
  int _rightStoveSeconds = 0;
  Timer? _leftStoveTimer;
  Timer? _rightStoveTimer;
  bool _abnormalFire = false;
  Timer? _pollTimer;
  bool _alertShown = false;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchStoveStatus();
    });
    _fetchStoveStatus();
  }

  Future<void> _fetchStoveStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://159.223.81.124:8000/stove_status/latest'),
        //Uri.parse('http://127.0.0.1:8000/stove_status/latest'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> stoveData = jsonDecode(response.body);

        if (stoveData['image'] != null && stoveData['image'].isNotEmpty) {
          try {
            imageBytes = base64Decode(stoveData['image']);
          } catch (e) {
            print('Error decoding Base64 image: $e');
          }
        }

        setState(() {
          _leftStoveOn = stoveData['left_stove_status'] == 'frame_on';
          _rightStoveOn = stoveData['right_stove_status'] == 'frame_on';
          bool newAbnormalFire = stoveData['abnormal_fire'] ?? false;

          if (newAbnormalFire && !_abnormalFire && !_alertShown) {
            _abnormalFire = newAbnormalFire;
            _showSlideToConfirmDialog(imageBytes);
          } else {
            _abnormalFire = newAbnormalFire;
          }

          if (_leftStoveOn) {
            if (_leftStoveTimer == null || !_leftStoveTimer!.isActive) {
              _leftStoveSeconds = 0;
              _leftStoveTimer = Timer.periodic(const Duration(seconds: 1), (
                timer,
              ) {
                setState(() {
                  _leftStoveSeconds++;
                });
              });
            }
          } else {
            _leftStoveTimer?.cancel();
            _leftStoveSeconds = 0;
          }

          if (_rightStoveOn) {
            if (_rightStoveTimer == null || !_rightStoveTimer!.isActive) {
              _rightStoveSeconds = 0;
              _rightStoveTimer = Timer.periodic(const Duration(seconds: 1), (
                timer,
              ) {
                setState(() {
                  _rightStoveSeconds++;
                });
              });
            }
          } else {
            _rightStoveTimer?.cancel();
            _rightStoveSeconds = 0;
          }
        });
      } else {
        log('Failed to fetch stove status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching stove status: $e');
    }
  }

  void _showSlideToConfirmDialog(Uint8List? imageBytes) {
    double sliderValue = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '安全警告',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('檢測到異常火焰!', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text('請確認您已關閉爐火', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  // 顯示 Base64 圖片
                  if (imageBytes != null)
                    Image.memory(
                      imageBytes,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Text('無法加載圖片'),
                    )
                  else
                    const Text('無圖片可用'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbColor: Colors.green,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 18.0,
                        ),
                        activeTrackColor: Colors.green[300],
                        inactiveTrackColor: Colors.grey[400],
                        trackHeight: 36.0,
                        overlayColor: Color.fromRGBO(76, 175, 80, 0.2),
                        activeTickMarkColor: Colors.green,
                        inactiveTickMarkColor: Colors.grey,
                        valueIndicatorColor: Colors.green,
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: sliderValue == 100 ? '已確認' : '滑動確認',
                              onChanged: (value) {
                                setState(() {
                                  sliderValue = value;
                                });
                              },
                              onChangeEnd: (value) {
                                if (value == 100) {
                                  Navigator.of(context).pop();
                                  this.setState(() {
                                    _alertShown = false;
                                  });
                                } else {
                                  setState(() {
                                    sliderValue = 0;
                                  });
                                }
                              },
                            ),
                          ),
                          if (sliderValue == 100)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sliderValue == 100 ? '已確認安全' : '請滑動滑塊確認安全',
                    style: TextStyle(
                      color: sliderValue == 100 ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
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

  void _toggleLeftStove() {
    setState(() {
      _leftStoveOn = !_leftStoveOn;
      if (_leftStoveOn) {
        _leftStoveSeconds = 0;
        _leftStoveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _leftStoveSeconds++;
          });
        });
      } else {
        _leftStoveTimer?.cancel();
        _leftStoveSeconds = 0;
      }
    });
  }

  void _toggleRightStove() {
    setState(() {
      _rightStoveOn = !_rightStoveOn;
      if (_rightStoveOn) {
        _rightStoveSeconds = 0;
        _rightStoveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _rightStoveSeconds++;
          });
        });
      } else {
        _rightStoveTimer?.cancel();
        _rightStoveSeconds = 0;
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget buildStoveTile(bool isOn, VoidCallback onTap, int seconds) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 260,
        decoration: BoxDecoration(
          color: isOn ? Colors.orange[50] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
              decoration: BoxDecoration(
                color: isOn ? Colors.deepOrange : Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOn ? '使用中' : '關閉',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 24,
              child:
                  isOn
                      ? Text(
                        _formatTime(seconds),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                isOn ? 'assets/fire_on.png' : 'assets/fire_off.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildStoveTile(_leftStoveOn, _toggleLeftStove, _leftStoveSeconds),
        const SizedBox(width: 20),
        buildStoveTile(_rightStoveOn, _toggleRightStove, _rightStoveSeconds),
      ],
    );
  }

  @override
  void dispose() {
    _leftStoveTimer?.cancel();
    _rightStoveTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}
