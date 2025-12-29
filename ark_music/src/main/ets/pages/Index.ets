// 导入模块
import { webview } from '@kit.ArkWeb';
import display from '@ohos.display';
import emitter from '@ohos.events.emitter';
import { common } from '@kit.AbilityKit';
import media from '@ohos.multimedia.media';
import { image } from '@kit.ImageKit';
import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit';
import { AVVolumePanel } from '@kit.AudioKit';
import { BusinessError} from '@kit.BasicServicesKit';
import picker from '@ohos.file.picker';
import util from '@ohos.util';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { fileUri } from  '@kit.CoreFileKit';
import { bundleManager } from '@kit.AbilityKit';

// 导入其他ets
import { scan_download } from './files_manager'

// 主程序 //
@Entry
@Component
struct ArkMusic_Component {

  // 变量/类池
  @State ark_music_ui: webview.WebviewController = new webview.WebviewController();
  @State allow_create_make_files: boolean = false;
  @State ark_create_download_ui: webview.WebviewController = new webview.WebviewController();
  ark_create_download_ui_delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();

  // 组件池 //
  // 初始化
  app_start() {
    // 扫描目录
    this.allow_create_make_files = scan_download();
    // 如果没创建好那先退出
    if (this.allow_create_make_files) {return;}
  }

  // UI界面构建 //
  build() {
    Row() {

      // ArkMusic主界面 //
      Web({src: $rawfile("webview_gui/index.html"), controller: this.ark_music_ui})
        .width('100vw')
        .height('100vh')
        .position({ x: 0, y: 0})
        .zIndex(500)
        .zoomAccess(false)
        // 加载前
        .onControllerAttached(() => {
          this.app_start();
        })
        // 加载后
        .onPageEnd(() => {})

      // 下载目录创建 //
      if (this.allow_create_make_files) {
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
                this.app_start();
              })
              this.ark_create_download_ui.setDownloadDelegate(this.ark_create_download_ui_delegate);
            } catch (error) {
              console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
            this.ark_create_download_ui.runJavaScript('download()')
          })
      }

    }
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
