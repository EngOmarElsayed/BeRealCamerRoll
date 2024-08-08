//
//  ResultedImageViewController.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import UIKit
import Combine
import LinkPresentation

class ResultedImageViewController: UIViewController {
  private let viewModel = FinalImageViewModel()
  private var cancellable = Set<AnyCancellable>()
  
  @IBOutlet var shareButton: UIButton!
  @IBOutlet var frontImageView: UIImageView!
  @IBOutlet var backImageView: UIImageView!
  @IBOutlet var finalImageView: UIView!
  
  @IBAction func doneAction(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func shareButton(_ sender: UIButton) {
    let shareSheet = UIActivityViewController(activityItems: [convertViewToImage(), self], applicationActivities: nil)
    present(shareSheet, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    viewModel.captureImages()
  }
}

extension ResultedImageViewController {
  private func setupViewController() {
    setupAppearance()
    subscribeToPublishers()
  }
  
  private func setupAppearance() {
    frontImageView.layer.borderWidth = 2.0
    frontImageView.layer.borderColor = UIColor.black.cgColor
    
    frontImageView.layer.cornerRadius = 20
    backImageView.layer.cornerRadius = 25
    
    frontImageView.clipsToBounds = true
    backImageView.clipsToBounds = true
    navigationItem.setHidesBackButton(true, animated: false)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleImagePlaces))
    frontImageView.addGestureRecognizer(tapGesture)
    frontImageView.isUserInteractionEnabled = true
    
    shareButton.backgroundColor = .black.withAlphaComponent(0.5)
    shareButton.layer.cornerRadius = 15
  }
  
  private func subscribeToPublishers() {
    viewModel.$frontImage.sink { [weak self] frontImage in
      guard let self else { return }
      frontImageView.image = frontImage
    }.store(in: &cancellable)
    
    viewModel.$backImage.sink { [weak self] backImage in
      guard let self else { return }
      backImageView.image = backImage
    }.store(in: &cancellable)
  }
  
  private func convertViewToImage() -> UIImage {
    let render = UIGraphicsImageRenderer(size: finalImageView.bounds.size)
    return render.image { _ in
      finalImageView.drawHierarchy(in: finalImageView.bounds, afterScreenUpdates: true)
    }
  }
  
  @objc private func toggleImagePlaces() {
    viewModel.toggleImagePlaces()
  }
}


extension ResultedImageViewController: UIActivityItemSource {
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return ""
  }
  
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    return nil
  }
  
  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let image = convertViewToImage()
    let imageProvider = NSItemProvider(object: image)
    let metadata = LPLinkMetadata()
    metadata.imageProvider = imageProvider
    return metadata
  }
  
  func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
    return convertViewToImage()
  }
}
