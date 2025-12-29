// 绑定元素
const taskbar = document.getElementById('taskbar');
const taskbar_selector = document.getElementById('taskbar_selector');

// 滑动允许指示
let able_move = true;

// 初始化selector
taskbar_selector.className = 'taskbar_selector main';

// 监听taskbar按下
taskbar.addEventListener('touchstart', function(e) {
    able_move = true;
    taskbar.className = 'taskbar active';
    music_bar.className = 'music_bar active';
});

// 监听taskbar松开（取消）
taskbar.addEventListener('toucancel', function(e) {
    taskbar.className = 'taskbar';
    music_bar.className = 'music_bar';
});

// 监听taskbar移动
taskbar.addEventListener('touchmove', function(e) {
    if (able_move) {
        // 获取值
        const rect = taskbar.getBoundingClientRect();
        const touch = e.touches[0];
        const x = touch.clientX;
        const y = touch.clientY;
        // 如果滑出边界
        if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
            // 滑出边界，复位
            taskbar.className = 'taskbar';
            music_bar.className = 'music_bar';
            able_move = false;
        }
    }
});

// 监听taskbar松开（点击）
taskbar.addEventListener('touchend', function(e) {

    // 获取触摸点信息
    const rect = taskbar.getBoundingClientRect();
    const touch = e.changedTouches[0];
    const clickX = touch.clientX - rect.left;
    const taskbarWidth = rect.width;
    
    // 复位
    taskbar.className = 'taskbar';
    
    // 如果点击在左半边
    if (clickX < taskbarWidth / 2) {
        // 滑块移动到播放页图标位置（左半边）
        taskbar_play();
        
    } else {
        // 否则点击在右半边
        // 滑块移动到文件页图标位置（右半边）
        taskbar_files();
    }
});

// 状态调节接口
// 播放页模式
function taskbar_play() {
    taskbar_selector.className = 'taskbar_selector main';
    taskbar.className = 'taskbar';
    hide_music_bar();
}
// 文件页模式
function taskbar_files() {
    taskbar_selector.className = 'taskbar_selector files';
    taskbar.className = 'taskbar';
    show_music_bar();
}
// 其他页模式
function taskbar_other() {
    taskbar.className = 'taskbar hide';
    sink_music_bar();
}