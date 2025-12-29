// 获取进度滑块和进度展示条元素
const playbackControl = document.getElementById('playback_control');
const playbackScreen = document.getElementById('music_bar_playback_screen');

// 初始化时设置进度展示条的宽度
updatePlaybackScreen();

// 监听进度滑块的变化事件
playbackControl.addEventListener('input', function() {
    console.log('Playback control value changed to: ' + playbackControl.value);
    updatePlaybackScreen();
});

// 更新进度展示条宽度的函数
function updatePlaybackScreen() {
    // 计算百分比宽度
    const min = parseFloat(playbackControl.min);
    const max = parseFloat(playbackControl.max);
    const value = parseFloat(playbackControl.value);
    
    // 计算百分比 (考虑最小值可能不为0的情况)
    const percentage = ((value - min) / (max - min)) * 100;
    
    // 设置进度展示条的宽度为计算出的百分比
    // playbackScreen.style.transform = 'translateX(-' + (100 - percentage) + '%)';
    playbackScreen.style.width = percentage + '%';
}

// 如果需要动态更新滑块范围，可以调用此函数来重新计算进度条
function updateRange(newMin, newMax) {
    playbackControl.min = newMin;
    playbackControl.max = newMax;
    updatePlaybackScreen(); // 更新显示
}