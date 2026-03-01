import 'package:flutter/material.dart';

class HistoryDialog extends StatelessWidget {
  final List<String> history;

  const HistoryDialog({super.key, required this.history});

  static void show(BuildContext context, List<String> history) {
    showDialog(
      context: context,
      builder: (context) => HistoryDialog(history: history),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFf4c025)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 300,
        height: 400,
        child: Column(
          children: [
            const Text(
              'MOVE HISTORY',
              style: TextStyle(
                color: Color(0xFFf4c025),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'No moves yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- ${history[index]}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf4c025),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
