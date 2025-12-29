// 绑定元素
const music_bar = document.getElementById('music_bar');
const music_bar_frame = document.getElementById('music_bar_frame');

// 改变状态接口
// 显示音乐栏
function show_music_bar() {
    music_bar.className = 'music_bar show';
    music_bar_frame.className = 'music_bar_frame show';
}
// 隐藏音乐栏
function hide_music_bar() {
    music_bar.className = 'music_bar';
    music_bar_frame.className = 'music_bar_frame';
}
// 音乐栏下沉
function sink_music_bar() {
    music_bar_frame.className = 'music_bar_frame show';
    music_bar.className = 'music_bar';
}