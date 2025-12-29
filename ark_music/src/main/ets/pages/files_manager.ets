// 模块池 //
import { bundleManager } from '@kit.AbilityKit';
import { picker, fileUri } from  '@kit.CoreFileKit';
import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';

// 变量池 //



// 函数块 //
// 下载器
export function getDownloadPathFromPicker(): Promise<string> {
  return new Promise<string>(resolve => {
    try {
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD
      const documentPicker = new picker.DocumentViewPicker();
      documentPicker.save(documentSaveOptions).then(async (documentSaveResult: Array<string>) => {
        if (documentSaveResult.length <= 0) {
          resolve('');
          return;
        }
        const uriString = documentSaveResult[0];
        if (!uriString) {
          resolve('');
          return;
        }
        const uri = new fileUri.FileUri(uriString);
        resolve(uri.path);
      }).catch((err: BusinessError) => {
        console.error(`ErrorCode: ${err.code},  Message: ${err.message}`);
        resolve('');
      });
    } catch (error) {
      resolve('');
    }
  })
}

// 检测是否有download目录
export function scan_download(): boolean {
  console.log('正在扫描目录...')
  try {
    // 获取bundleName
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
    let bundleName = bundleManager.getBundleInfoForSelfSync(bundleFlags).name;
    // 获取Download目录下应用包名对应的path
    let uri = 'file://docs/storage/Users/currentUser/Download/' + bundleName;
    let fileUriObject = new fileUri.FileUri(uri);
    let path = fileUriObject.path;
    // 尝试读取目录
    try {
      fs.listFileSync(path);
      // 目录可用，返回false，不允许创建目录
      console.log('目录存在。')
      return false;
    } catch (e) {
      // 找不到目录，返回true，创建目录
      console.log('目录不存在，请求创建...')
      return true;
    }

  } catch (e) {
    console.error(`扫描目录时出错：${e}`)
    console.error('重新创建目录。')
    return true;
  }
}

@Component
export struct create_new_files {

  // 变量池 //
  @State ark_create_download_ui: webview.WebviewController = new webview.WebviewController();
  ark_create_download_ui_delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();

  // 构建块
  build() {

    // 下载目录创建 //
    Web({src: $rawfile("create_gui/index.html"), controller: this.ark_create_download_ui})
      .width('100vw')
      .height('100vh')
      .position({ x: 0, y: 0})
      .zIndex(900)
      .zoomAccess(false)
      .onPageEnd(async () => {
        console.log('创建页准备完成...')
        try {
          this.ark_create_download_ui_delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {
            console.info("正在创建...");
            getDownloadPathFromPicker().then((downloadPath) => {
              webDownloadItem.start(downloadPath + '/' + webDownloadItem.getSuggestedFileName());
            });
          })
          this.ark_create_download_ui_delegate.onDownloadFinish(() => {
            console.info("创建完成！");
            scan_download();
          })
          this.ark_create_download_ui.setDownloadDelegate(this.ark_create_download_ui_delegate);
        } catch (error) {
          console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
        }
        this.ark_create_download_ui.runJavaScript('download()')
      })
  }
}