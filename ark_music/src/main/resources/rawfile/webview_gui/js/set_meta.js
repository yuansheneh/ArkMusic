function set_meta(tmp) {
    // 设置名字
    title.innerText = tmp[0];
    checkAndSetupScrolling()
    // 设置标题
    page_play.contentWindow.postMessage({
        type: 'play_page_update_title', arg1: tmp[1]
    }, '*');
    // 设置艺术家（副标题）
    page_play.contentWindow.postMessage({
        type: 'play_page_update_sub_title', arg1: tmp[2]
    }, '*')


}

function set_meta_img(tmp) {
    // 设置图片
    page_play.contentWindow.postMessage({
        type: 'play_page_update_img', arg1: tmp
    }, '*')
    set_song_image(tmp)
}

function set_song_image(byteString) {
    try {
        // 将数字数组字符串转换回字符，得到外层的base64
        let byteArrayStr = byteString.replace(/[\[\]]/g, '');
        let byteNumbers = byteArrayStr.split(',').map(num => parseInt(num.trim()));

        // 将数字数组转换回base64字符串
        let outerBase64 = '';
        for (let i = 0; i < byteNumbers.length; i++) {
            outerBase64 += String.fromCharCode(byteNumbers[i]);
        }

        // 解码外层base64，得到真正的Data URL定义
        let innerContent = atob(outerBase64);

        // 分离MIME类型和数字数组部分
        let [mimeTypePartWithBase64, numbersPart] = innerContent.split(';base64,');
        let mimeType = mimeTypePartWithBase64.replace(';base64', '');

        // 将数字字符串转换回真正的base64
        let numberArray = numbersPart.split(',').map(num => parseInt(num.trim()));
        let realBase64 = '';
        for (let i = 0; i < numberArray.length; i++) {
            realBase64 += String.fromCharCode(numberArray[i]);
        }

        // 解码base64为二进制数据
        let binaryData = atob(realBase64);

        // 转换为Uint8Array
        let uint8Array = new Uint8Array(binaryData.length);
        for (let i = 0; i < binaryData.length; i++) {
            uint8Array[i] = binaryData.charCodeAt(i);
        }

        // 创建Blob对象
        let blob = new Blob([uint8Array], { type: mimeType });
        let blobUrl = URL.createObjectURL(blob);

        const img = new Image();

        img.onload = function() {
            // 加载成功，清空div并添加新图片
            meta_img.innerHTML = '';
            meta_img.appendChild(img);
            
            // 获取图片平均色并设置为body背景色
            getAverageColorAndSetBackground(img);
            
            // 使用完成后释放blob URL以节省内存
            img.onload = null; // 清除事件处理器
        };

        img.onerror = function() {
            // 加载失败，清空div并添加默认图片
            meta_img.innerHTML = '';
            const defaultImg = new Image();
            defaultImg.src = 'file/CD.png';
            meta_img.appendChild(defaultImg);
            // 释放失败的blob URL
            URL.revokeObjectURL(blobUrl);
        };

        // 设置src
        img.src = blobUrl;

    } catch (error) {
        // 发生错误，添加默认图片
        meta_img.innerHTML = '';
        const defaultImg = new Image();
        defaultImg.src = 'file/CD.png';
        meta_img.appendChild(defaultImg);
    }
}

// 新增函数：获取图片平均色值并设置为body背景色
function getAverageColorAndSetBackground(img) {
    try {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        
        // 设置canvas尺寸为图片尺寸（可以缩小处理以提高性能）
        const width = img.width;
        const height = img.height;
        
        canvas.width = width;
        canvas.height = height;
        
        // 绘制图片到canvas
        ctx.drawImage(img, 0, 0, width, height);
        
        // 获取图片像素数据
        const imageData = ctx.getImageData(0, 0, width, height);
        const data = imageData.data;
        
        let r = 0, g = 0, b = 0;
        let count = 0;
        
        // 计算所有像素的平均颜色
        for (let i = 0; i < data.length; i += 4) {
            // 跳过完全透明的像素
            if (data[i + 3] !== 0) {
                r += data[i];
                g += data[i + 1];
                b += data[i + 2];
                count++;
            }
        }
        
        if (count > 0) {
            r = Math.floor(r / count);
            g = Math.floor(g / count);
            b = Math.floor(b / count);
        } else {
            // 如果没有有效像素，使用默认颜色
            r = 128;
            g = 128;
            b = 128;
        }
        
        // 设置body背景色
        document.body.style.backgroundColor = `rgb(${r}, ${g}, ${b})`;
        
        // 清理canvas
        canvas.width = 0;
        canvas.height = 0;
        
    } catch (error) {
        console.error('获取图片平均色时出错:', error);
        // 出错时使用默认颜色
        document.body.style.backgroundColor = '#808080'; // 灰色
    }
}
