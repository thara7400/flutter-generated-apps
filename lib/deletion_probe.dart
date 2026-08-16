/// 残骸削除パスの実 push 検証用の捨てファイル(現在地 §2 項番14 / [MEAS-001] 段階C)。
///
/// このファイルは A(本ファイルあり)→ B(なし)の順に `m1:push -- --push` して、
/// **commit B の file list に `removed` が出るか**だけを見るための治具。
/// アプリからは一切参照されないので、`flutter analyze` は未参照のまま通る
/// (未使用 import が無ければ analyzer は未参照のトップレベル宣言を咎めない)。
///
/// ⚠️ 生成物ではない。`buildTreeEntries()` の削除処理が実 push でも効くことを
/// 確かめたら、B の push でリポジトリから消える。
library;

const String deletionProbeMarker = 'deletion-probe-20260814';
