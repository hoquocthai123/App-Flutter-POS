import 'package:flutter/material.dart';

class PointPage extends StatelessWidget {
  final Map customer;

  const PointPage({super.key, required this.customer});

  String getRank(int points) {
    if (points >= 150000) {
      return "Kim cương";
    } else if (points >= 50000) {
      return "Vàng";
    } else if (points >= 10000) {
      return "Đồng";
    } else {
      return "Thành viên";
    }
  }

  int getNextRankPoints(int currentPoints) {
    if (currentPoints < 10000) return 10000 - currentPoints;
    if (currentPoints < 50000) return 50000 - currentPoints;
    if (currentPoints < 150000) return 150000 - currentPoints;
    return 0;
  }

  Widget _buildRankCard(String rank, int requiredPoints, bool isActive) {
    return Card(
      elevation: 4,
      color: isActive ? Colors.amber[100] : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              rank,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.amber[900] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$requiredPoints điểm',
              style: TextStyle(
                fontSize: 16,
                color: isActive ? Colors.amber[900] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPoints = customer["points"] as int;
    final currentRank = getRank(currentPoints);
    final pointsToNextRank = getNextRankPoints(currentPoints);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin hạng thành viên'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Điểm hiện tại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[300]!, Colors.amber[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Điểm tích lũy của bạn',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${customer["points"]} điểm',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hạng: $currentRank',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (pointsToNextRank > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Cần thêm $pointsToNextRank điểm để lên hạng tiếp theo',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Các hạng thành viên:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách các hạng
            _buildRankCard('Kim cương', 150000, currentRank == 'Kim cương'),
            const SizedBox(height: 8),
            _buildRankCard('Vàng', 50000, currentRank == 'Vàng'),
            const SizedBox(height: 8),
            _buildRankCard('Đồng', 10000, currentRank == 'Đồng'),
            const SizedBox(height: 8),
            _buildRankCard('Thành viên', 0, currentRank == 'Thành viên'),

            const SizedBox(height: 24),
            
          ],
        ),
      ),
    );
  }
}