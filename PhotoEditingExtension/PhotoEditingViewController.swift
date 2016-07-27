/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This view controller provides the UI for the photo edting extension in iOS.
 */

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController, ContentEditingDelegate {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    var input: PHContentEditingInput?

    // Shared object to handle editing in both iOS and OS X
    lazy var editController = ContentEditingController()

    // ContentEditingDelegate callbacks to UI
    var preselectedFilterIndex: Int?
    var previewImage: CIImage?
    var previewLivePhoto: PHLivePhoto? {
        didSet {
            livePhotoView.livePhoto = previewLivePhoto
            livePhotoView.contentMode = .scaleAspectFit
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let index = preselectedFilterIndex {
            let indexPath = IndexPath(row: index, section: 0)
            collectionView!.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            updateSelection(for: collectionView.cellForItem(at: indexPath)!)
        }
    }
}

// MARK: PHContentEditingController
extension PhotoEditingViewController: PHContentEditingController {

    //能不能处理
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool{
        return editController.canHandle(adjustmentData)
    }
    
    
    //开始编辑，调起extension，给PHContentEditingInput和image
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage){
                        // Except here: show the image preview before forwarding.
                        previewImageView.image = placeholderImage
                        backgroundImageView.image = placeholderImage
                        collectionView.reloadData()
                //input.displaySizeImage
                        editController.startContentEditing(with: contentEditingInput)
    }
    
    
    //点击完成
    func finishContentEditing(completionHandler: (PHContentEditingOutput) -> Swift.Void){
                        editController.finishContentEditing { (editingOutput) in
        
                        }
    }
    
    
    // 取消编辑
    func cancelContentEditing(){
                    editController.cancelContentEditing()

    }
    
    
    // 是否有取消确认
    var shouldShowCancelConfirmation: Bool {
        return editController.shouldShowCancelConfirmation

    }

    
    
    
//    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
//        return editController.canHandle(adjustmentData)
//    }
//    
//    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
//                // Except here: show the image preview before forwarding.
//                previewImageView.image = placeholderImage
//                backgroundImageView.image = placeholderImage
//                collectionView.reloadData()
//        
//                editController.startContentEditing(with: contentEditingInput)
//    }
//    
//    func finishContentEditing(completionHandler: ((PHContentEditingOutput?) -> Void)) {
//        // Update UI to reflect that editing has finished and output is being rendered.
//                editController.finishContentEditing { (editingOutput) in
//        
//                }
////        // Render and provide output on a background queue.
////        DispatchQueue.global(attributes: [.qosDefault]).async {
////            // Create editing output from the editing input.
////            let output = PHContentEditingOutput(contentEditingInput: self.input!)
////            
////            // Provide new adjustments and render output to given location.
////            // output.adjustmentData = <#new adjustment data#>
////            // let renderedJPEGData = <#output JPEG#>
////            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
////            
////            // Call completion handler to commit edit to Photos.
////            completionHandler(output)
////            
////            // Clean up temporary files, etc.
////        }
//    }
//    
//    var shouldShowCancelConfirmation: Bool {
//                return editController.shouldShowCancelConfirmation
//
//    }
//    
//    func cancelContentEditing() {
//            editController.cancelContentEditing()
//
//    }

}

// Cell class for collection view
class PhotoFilterCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
}

// MARK: UICollectionViewDataSource
extension PhotoEditingViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editController.filterNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(PhotoFilterCell.self), for: indexPath) as? PhotoFilterCell
            else { fatalError("unexpected cell in storyboard") }

        let filterName = editController.filterNames[indexPath.item!]
        if filterName == editController.wwdcFilter {
            cell.filterNameLabel.text = editController.wwdcFilter
        } else {
            // Query Core Image for filter's display name.
            let filter = CIFilter(name: filterName)!
            let filterDisplayName = filter.attributes[kCIAttributeFilterDisplayName]! as! String
            cell.filterNameLabel.text = filterDisplayName
        }
        // Show the preview image defined by the editing controller.
        //缩略图
        if let images = editController.previewImages {
            cell.imageView.image = UIImage(ciImage: images[indexPath.item!])
        }

        return cell
    }
}

// MARK: UICollectionViewDelegate
extension PhotoEditingViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelection(for: collectionView.cellForItem(at: indexPath)!)

        let filterName = editController.filterNames[indexPath.item!]
        editController.selectedFilterName = filterName

        // Edit controller has already defined preview images for all filters,
        // so just switch the big preview to the right one.
        if let images = editController.previewImages {
            previewImage = images[indexPath.item!]
            previewImageView.image = UIImage(ciImage: previewImage!)
        }

        if #available(iOSApplicationExtension 10.0, *) {
            editController.updateLivePhotoIfNeeded() // applies filter, sets previewLivePhoto on completion
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateSelection(for: collectionView.cellForItem(at: indexPath)!)
    }

    func updateSelection(for cell: UICollectionViewCell) {
        guard let cell = cell as? PhotoFilterCell else { fatalError("unexpected cell") }

        cell.imageView.layer.borderColor = view.tintColor.cgColor
        cell.imageView.layer.borderWidth = cell.isSelected ? 2 : 0

        cell.filterNameLabel.textColor = cell.isSelected ? view.tintColor : .white()
    }
}
