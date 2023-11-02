//
//  GHNewScanViewController.swift
//  GHAuthManager
//
//  Created by songyang on 2023/10/20.
//

import UIKit
import Foundation
import AVFoundation

public protocol GHScanViewControllerDelegate: class {
     func scanFinished(scanResult: GHScanResult, error: String?)
}

public protocol QRRectDelegate {
    func drawwed()
}

open class GHNewScanViewController: UIViewController {
    
    // 返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
    open weak var scanResultDelegate: GHScanViewControllerDelegate?

    open var delegate: QRRectDelegate?

    open var scanObj: GHScanWrapper?

    open var scanStyle: GHScanViewStyle? = GHScanViewStyle()

    open var qRScanView: GHScanView?

    // 启动区域识别功能
    open var isOpenInterestRect = false
    
    //连续扫码
    open var isSupportContinuous = false;

    // 识别码的类型
    public var arrayCodeType: [AVMetadataObject.ObjectType]?

    // 是否需要识别后的当前图像
    public var isNeedCodeImage = false

    // 相机启动提示文字
    public var readyString = ""

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // [self.view addSubview:_qRScanView];
        view.backgroundColor = UIColor.black
//        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }

    open func setNeedCodeImage(needCodeImg: Bool) {
        isNeedCodeImage = needCodeImg
    }

    // 设置框内识别
    open func setOpenInterestRect(isOpen: Bool) {
        isOpenInterestRect = isOpen
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawScanView()
        perform(#selector(GHNewScanViewController.startScan), with: nil, afterDelay: 0.3)
    }

    @objc open func startScan() {
        if scanObj == nil {
            var cropRect = CGRect.zero
            if isOpenInterestRect {
                cropRect = GHScanView.getScanRectWithPreView(preView: view, style: scanStyle!)
            }

            // 指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString,
                                 AVMetadataObject.ObjectType.ean13 as NSString,
                                 AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }

            scanObj = GHScanWrapper(videoPreView: view,
                                     objType: arrayCodeType!,
                                     isCaptureImg: isNeedCodeImage,
                                     cropRect: cropRect,
                                     success: { [weak self] (arrayResult) -> Void in
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        if !strongSelf.isSupportContinuous {
                                            // 停止扫描动画
                                            strongSelf.qRScanView?.stopScanAnimation()
                                        }
                                        strongSelf.handleCodeResult(arrayResult: arrayResult)
                                     })
        }
        
        scanObj?.supportContinuous = isSupportContinuous;

        // 结束相机等待提示
        qRScanView?.deviceStopReadying()

        // 开始扫描动画
        qRScanView?.startScanAnimation()

        // 相机运行
        scanObj?.start()
    }
    
    open func drawScanView() {
        if qRScanView == nil {
            qRScanView = GHScanView(frame: view.frame, vstyle: scanStyle!)
            view.addSubview(qRScanView!)
            delegate?.drawwed()
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)
    }
   

    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult: [GHScanResult]) {
        guard let delegate = scanResultDelegate else {
            fatalError("you must set scanResultDelegate or override this method without super keyword")
        }
        
        if arrayResult.isEmpty {
            return
        }
        
        if !isSupportContinuous {
            navigationController?.popViewController(animated: true)

        }
        
        if let result = arrayResult.first {
            delegate.scanFinished(scanResult: result, error: nil)
        } else {
            let result = GHScanResult(str: nil, img: nil, barCodeType: nil, corner: nil)
            delegate.scanFinished(scanResult: result, error: "no scan result")
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        qRScanView?.stopScanAnimation()
        scanObj?.stop()
    }
    
    @objc open func openPhotoAlbum() {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
}

//MARK: - 图片选择代理方法
extension GHNewScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let image = editedImage ?? originalImage else {
            return
        }
        let arrayResult = GHScanWrapper.recognizeQRImage(image: image)
        handleCodeResult(arrayResult: arrayResult)
    }
    
}

//MARK: - 私有方法
private extension GHNewScanViewController {
    
    func showMsg(title: String?, message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
