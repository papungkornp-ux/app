class MeritItem {
  final String id;
  final String title;
  final String subtitle;
  final bool supportsMinutes;

  const MeritItem(
    this.id,
    this.title,
    this.subtitle, {
    this.supportsMinutes = false,
  });
}

const buddhistMerits = [
  MeritItem('morning_chant', 'ทำวัตรเช้า', 'เริ่มต้นวันด้วยสติ'),
  MeritItem('evening_chant', 'ทำวัตรเย็น', 'ทบทวนใจในยามค่ำ'),
  MeritItem('precepts5', 'รักษาศีล 5', 'ตั้งใจรักษาศีลในวันนี้'),
  MeritItem('precepts8', 'รักษาศีล 8', 'เพิ่มความสำรวมและเรียบง่าย'),
  MeritItem('meditate','นั่งสมาธิ','ฝึกจิตวันนี้',),
  MeritItem('cleaning', 'ทำความสะอาด', 'ดูแลพื้นที่และสิ่งรอบตัว'),
  MeritItem('dharma', 'ฟังธรรม', 'เปิดใจเรียนรู้ธรรมะ'),
];

const islamicMerits = [
  MeritItem('daily_prayer', 'ละหมาด 5 เวลา', 'รักษาเวลาละหมาดตลอดวัน'),
  MeritItem('quran', 'อ่านอัลกุรอาน', 'ใช้เวลาเรียนรู้และใคร่ครวญ'),
  MeritItem('charity', 'บริจาค', 'แบ่งปันด้วยความเมตตา'),
  MeritItem('fasting', 'ถือศีลอด', 'ฝึกความอดทนและความสำรวม'),
  MeritItem('mosque', 'ไปมัสยิด', 'ร่วมศาสนกิจและชุมชน'),
  MeritItem('dua', 'ขอดุอาร์', 'วิงวอนและระลึกถึงอัลลอฮ์'),
];

List<MeritItem> getMeritItemsForReligion(String religion) {
  if (religion == 'อิสลาม') {
    return islamicMerits;
  }
  return buddhistMerits;
}
