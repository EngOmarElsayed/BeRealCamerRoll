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
  private var initialCenter: CGPoint = .zero
  private var cancellable = Set<AnyCancellable>()
  
  @IBOutlet var shareButton: UIButton!
  @IBOutlet var frontImageView: UIImageView!
  @IBOutlet var backImageView: UIImageView!
  @IBOutlet var finalImageView: UIView!
  
  @IBAction func doneAction(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func shareButton(_ sender: UIButton) {
    let shareSheet = UIActivityViewController(activityItems: [finalImageView.convertViewToImage(), self], applicationActivities: nil)
    present(shareSheet, animated: true)
  }
  
  @IBAction func toggleImagePlaces(_ gestureRecognizer : UITapGestureRecognizer) {
    viewModel.toggleImagePlaces()
  }
  
  @IBAction func dragGestureAction(_ gestureRecognizer : UIPanGestureRecognizer) {
    let translation = gestureRecognizer.translation(in: frontImageView.superview)
    switch gestureRecognizer.state {
    case .began:
      initialCenter = frontImageView.center
    case .changed:
      let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
      frontImageView.center = newCenter
    default:
      frontImageView.center = CGPoint(x: backImageView.frame.maxX*0.81, y: initialCenter.y)
      if translation.x < backImageView.frame.maxX/2-10 {
        frontImageView.center = CGPoint(x: backImageView.frame.maxX*0.19, y: initialCenter.y)
      } else {
        frontImageView.center = CGPoint(x: backImageView.frame.maxX*0.81, y: initialCenter.y)
      }
    }
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
    let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragGestureAction))
    frontImageView.addGestureRecognizer(dragGesture)
    
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
}

//MARK: -UIActivityItemSource
extension ResultedImageViewController: UIActivityItemSource {
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return ""
  }
  
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    return nil
  }
  
  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let image = finalImageView.convertViewToImage()
    let imageProvider = NSItemProvider(object: image)
    let metadata = LPLinkMetadata()
    metadata.imageProvider = imageProvider
    return metadata
  }
}
