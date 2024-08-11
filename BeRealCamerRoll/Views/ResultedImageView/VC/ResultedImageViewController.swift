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
    shareButton.menu = sharingImageMenuOptions()
    shareButton.showsMenuAsPrimaryAction = true
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
  
  private func sharingImageMenuOptions() -> UIMenu {
    var actions: [UIAction] = []
    for option in SharingImageOption.allCases {
      let action = UIAction(title: option.rawValue) { [weak self] action in
        guard let self else { return }
        let shareSheet = UIActivityViewController(activityItems: imagesToShare(for: option), applicationActivities: nil)
        present(shareSheet, animated: true)
      }
      
      actions.append(action)
    }
    
    return UIMenu(title: "", image: UIImage(systemName: "ellipsis.circle"), children: actions)
  }
  
  private func imagesToShare(for option: SharingImageOption) -> [Any] {
    var imagesToShare = [Any]()
    switch option {
    case .BeRealImage:
      imagesToShare = [finalImageView.convertViewToImage()]
    case .frontImage:
      imagesToShare = [frontImageView.image!]
    case .backImage:
      imagesToShare = [backImageView.image!]
    case .all:
      imagesToShare = [finalImageView.convertViewToImage(), frontImageView.image!, backImageView.image!]
    }
    return imagesToShare
  }
}
