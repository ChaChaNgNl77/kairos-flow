import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart'; // Hive 필수
import '../models/archive_item.dart'; // 모델 가져오기
import 'archive_detail_screen.dart';
import 'home_screen.dart'; // [필수] 홈 화면으로 이동하기 위해 추가

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F1F1F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Archive',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // [추가됨] 홈 버튼 (ArchiveDetailScreen과 동일한 위치)
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Color(0xFF1F1F1F)),
            onPressed: () {
              // 홈으로 이동하면서 이전 화면 스택 모두 지우기
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(hasSavedData: true),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8), // 오른쪽 여백
        ],
      ),
      // [핵심] Hive 박스를 구독해서 데이터가 바뀔 때마다 화면을 새로 그림
      body: ValueListenableBuilder(
        valueListenable: Hive.box<ArchiveItem>('archives').listenable(),
        builder: (context, Box<ArchiveItem> box, _) {
          // 1. 데이터가 없을 때 표시할 화면
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No archives yet.\nStart your first journey!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 2. 데이터가 있을 때 (최신순 정렬: 뒤집어서 리스트로 만듦)
          final items = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildArchiveCard(item);
            },
          );
        },
      ),
    );
  }

  // [수정] 인자로 ArchiveItem 객체 자체를 받음
  Widget _buildArchiveCard(ArchiveItem item) {
    return GestureDetector(
      onTap: () async {
        // [Navigation] 상세 화면으로 이동
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArchiveDetailScreen(item: item),
          ),
        );

        // [DB Update] 돌아왔을 때 '해결됨' 신호(true)를 받으면 DB 수정
        if (result == true) {
          item.isSolved = true; // 메모리 상에서 변경
          item.save(); // [중요] Hive DB에 영구 저장! (화면 자동 갱신됨)
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // [Stack] 도장을 위에 찍기 위해 사용
        child: Stack(
          children: [
            // 1. 카드 본문 디자인
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E4B28).withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 및 북마크 아이콘
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.bookmark,
                        color: const Color(0xFF2E4B28).withOpacity(0.6),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 고민 제목
                  Text(
                    item.concern,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // 결정 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4B28).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF2E4B28),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.decision,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E4B28),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. SOLVED 도장 (DB의 isSolved가 true일 때만 보임)
            if (item.isSolved)
              Positioned(
                top: 20,
                right: 20,
                child: Transform.rotate(
                  angle: -math.pi / 12, // 약간 기울기
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red.withOpacity(0.7),
                        width: 4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'SOLVED',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.7),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
