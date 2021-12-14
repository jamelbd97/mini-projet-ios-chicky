//
//  Accueil.swift
//  Chicky
//
//  Created by Mac2021 on 15/11/2021.
//

import UIKit
import AVKit
import AVFoundation

class AccueilView: UIViewController  {
    
    var player : AVPlayer? = AVPlayer()
    // VAR
    var moviePlayer: AVPlayerViewController?
    
    var liked = false
    var publications : [Publication] = []
    var publicationCounter = 0
    var isInitialized = false
    
    var previousPublication : Publication?
    var currentPublication : Publication?
    var nextPublication : Publication?
    
    var previousPublicationView = UIView()
    var currentPublicationView = UIView()
    var nextPublicationView = UIView()
    
    // WIDGET
    @IBOutlet weak var swipeAreaView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var publicationImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // PROTOCOLS
    
    // LIFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentairesSegue" {
            let destination = segue.destination as! CommentairesView
            destination.publication = currentPublication
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        publicationCounter = 0
        currentPublication = nil
        
        previousPublicationView.frame = CGRect(x: 0, y: -1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        
        currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        
        nextPublicationView.frame = CGRect(x: 0, y: 1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        
        swipeAreaView.addSubview(previousPublicationView)
        swipeAreaView.addSubview(currentPublicationView)
        swipeAreaView.addSubview(nextPublicationView)
        
        PublicationViewModel().recupererToutPublication { [self] success, results in
            if success {
                self.publications.append(contentsOf: results!)
                
                if publications.count > 0 {
                    setupPublications()
                    isInitialized = true
                }
            }
        }
    }
    
    // METHODS
    func setupPublications(){
        
        print("Counter is :" + String(publicationCounter))
        print("-----------")
        if publicationCounter > 0  {
            print("making previousPub")
            previousPublication = publications[publicationCounter - 1]
            waitForImage(element: previousPublicationView, elementIndex: -1, publication: previousPublication!)
        } else {
            previousPublication = nil
        }
        
        if publications.count >= publicationCounter {
            print("making currentPub")
            currentPublication = publications[publicationCounter]
            waitForImage(element: currentPublicationView, elementIndex: 0, publication: currentPublication!)
        }
        
        if publications.count > publicationCounter + 1  {
            print("making nextPub")
            nextPublication = publications[publicationCounter + 1]
            waitForImage(element: nextPublicationView, elementIndex: 1, publication: nextPublication!)
        } else {
            nextPublication = nil
        }
        print("-----------")
    }
    
    func waitForImage(element: UIView, elementIndex: Int, publication : Publication) {
        ImageLoader.shared.loadImage(
            identifier: publication.idPhoto!,
            url: Constantes.images + publication.idPhoto!,
            completion: { [self]image in
                makePublicationCard(card: element, elementIndex: elementIndex, description: publication.description!, uiImage: image!)
            })
    }
    
    func makePublicationCard(card: UIView, elementIndex: Int, description: String , uiImage: UIImage) {
        
        //CARD
        card.layer.cornerRadius = ROUNDED_RADIUS
        card.layer.shadowOffset = CGSize(width: 0,height: 0)
        card.layer.shadowRadius = ROUNDED_RADIUS
        card.layer.shadowOpacity = 0.4
        
        // GRADIENT
        let gradientView = GradientView()
        gradientView.secondColor = UIColor.black
        gradientView.frame = CGRect(x: 0, y: card.frame.height/2 , width: card.frame.width, height: card.frame.height/2)
        gradientView.layer.cornerRadius = ROUNDED_RADIUS
        
        // VIDEO
        guard let path = Bundle.main.path(forResource: "video", ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        playerLayer.frame = card.bounds
        playerLayer.cornerRadius = ROUNDED_RADIUS
        playerLayer.masksToBounds = true
        
        // DESCRIPTION
        let descriptionLabel = UILabel()
        descriptionLabel.tag = 2
        descriptionLabel.text = description
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.frame = CGRect(x: 30, y: card.frame.height - 150, width: card.frame.width, height: 50)
        
        // STARS
        let star1 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star1.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star1.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star2 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star2.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star2.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star3 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star3.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star3.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star4 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star4.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star4.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star5 = UIImageView(image: UIImage(named: "icon-star-empty"))
        star5.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star5.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        // RATING STACK VIEW
        let ratingStackView = UIStackView()
        ratingStackView.frame = CGRect(x: 30, y: card.frame.height - 100, width: 125, height: 25)
        ratingStackView.addArrangedSubview(star1)
        ratingStackView.addArrangedSubview(star2)
        ratingStackView.addArrangedSubview(star3)
        ratingStackView.addArrangedSubview(star4)
        ratingStackView.addArrangedSubview(star5)
        
        ratingStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccueilView.showRatingAction)))
        
        // ADD RATING BUTTON
        let likeButton = UIButton()
        likeButton.setImage(UIImage(named: "icon-favorites-filled"), for: .normal)
        likeButton.setTitleColor(UIColor.white, for: .normal)
        likeButton.frame = CGRect(x: 25, y: card.frame.height - 60, width: 30, height: 30)
        likeButton.addTarget(self, action: #selector(AccueilView.likeButtonAction), for: .touchUpInside)
        
        // COMMENT BUTTON
        let commentButton = UIButton()
        commentButton.setImage(UIImage(named: "icon-comment"), for: .normal)
        commentButton.setTitleColor(UIColor.white, for: .normal)
        commentButton.frame = CGRect(x: 60, y: card.frame.height - 60, width: 30, height: 30)
        commentButton.addTarget(self, action: #selector(AccueilView.showCommentsAction), for: .touchUpInside)
        
        // CARD SUBVIEWS
        card.layer.addSublayer(playerLayer)
        player!.play()
        card.addSubview(gradientView)
        card.addSubview(descriptionLabel)
        card.addSubview(ratingStackView)
        card.addSubview(likeButton)
        card.addSubview(commentButton)
    }
    
    func navigateToNextPublication() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // put here the code you would like to animate
            self.previousPublicationView.frame.origin.y -= 1000
            self.currentPublicationView.frame.origin.y -= 1000
            self.nextPublicationView.frame.origin.y -= 1000
        }, completion: { [self](finished:Bool) in
            
            previousPublicationView.backgroundColor = UIColor.red
            previousPublicationView.frame = CGRect(x: 0, y: -1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            currentPublicationView.backgroundColor = UIColor.green
            currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            nextPublicationView.backgroundColor = UIColor.blue
            nextPublicationView.frame = CGRect(x: 0, y: 1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            setupPublications()
        })
    }
    
    func navigateToPreviousPublication() {
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // put here the code you would like to animate
            self.previousPublicationView.frame.origin.y += 1000
            self.currentPublicationView.frame.origin.y += 1000
            self.nextPublicationView.frame.origin.y += 1000
        }, completion: { [self](finished:Bool) in
            previousPublicationView.backgroundColor = UIColor.red
            previousPublicationView.frame = CGRect(x: 0, y: -1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            currentPublicationView.backgroundColor = UIColor.green
            currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            nextPublicationView.backgroundColor = UIColor.blue
            nextPublicationView.frame = CGRect(x: 0, y: 1000, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            
            setupPublications()
        })
    }
    
    var star1 : UIButton = UIButton()
    var star2 : UIButton = UIButton()
    var star3 : UIButton = UIButton()
    var star4 : UIButton = UIButton()
    var star5 : UIButton = UIButton()
    
    var noteAcutelle: Int?
    var noteChoisi: Int?
    
    @objc func showRatingAction(sender: UIButton) {
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        initializeStarButton(starButton: star1, isEmpty: true)
        initializeStarButton(starButton: star2, isEmpty: true)
        initializeStarButton(starButton: star3, isEmpty: true)
        initializeStarButton(starButton: star4, isEmpty: true)
        initializeStarButton(starButton: star5, isEmpty: true)
        
        EvaluationViewModel().recupererEvaluationParUtilisateur(idPublication: currentPublication?._id) { [self] success, evaluationRep in
            if success {
                self.noteAcutelle = evaluationRep?.note
                
                var hasNote = false
                
                if noteAcutelle != 0 {
                    hasNote = true
                }
                
                print("noteAcutelle")
                print(noteAcutelle!)
                
                if hasNote {
                    initializeStarButton(starButton: star1, isEmpty: noteAcutelle! <= 0)
                    initializeStarButton(starButton: star2, isEmpty: noteAcutelle! <= 1)
                    initializeStarButton(starButton: star3, isEmpty: noteAcutelle! <= 2)
                    initializeStarButton(starButton: star4, isEmpty: noteAcutelle! <= 3)
                    initializeStarButton(starButton: star5, isEmpty: noteAcutelle! <= 4)
                }
                
                star1.addTarget(self, action: #selector(AccueilView.hoverStar1), for: .touchUpInside)
                star2.addTarget(self, action: #selector(AccueilView.hoverStar2), for: .touchUpInside)
                star3.addTarget(self, action: #selector(AccueilView.hoverStar3), for: .touchUpInside)
                star4.addTarget(self, action: #selector(AccueilView.hoverStar4), for: .touchUpInside)
                star5.addTarget(self, action: #selector(AccueilView.hoverStar5), for: .touchUpInside)
                
                let ratingStackView = UIStackView(frame: CGRect(x: 130, y: 20, width: 125, height: 25))
                ratingStackView.addArrangedSubview(star1)
                ratingStackView.addArrangedSubview(star2)
                ratingStackView.addArrangedSubview(star3)
                ratingStackView.addArrangedSubview(star4)
                ratingStackView.addArrangedSubview(star5)
                
                let addRatingLabel = UILabel(frame: CGRect(x: 8, y: 70, width: 380, height: 25))
                addRatingLabel.textColor = UIColor.gray
                addRatingLabel.text = "Please choose your rating"
                addRatingLabel.textAlignment = .center
                
                actionSheet.view.addSubview(ratingStackView)
                actionSheet.view.addSubview(addRatingLabel)
                
                if noteAcutelle != nil {
                    actionSheet.addAction(UIAlertAction(title: "Delete my rating", style: .destructive, handler: { act in
                        EvaluationViewModel().supprimerEvaluation(_id: "") { success in
                            if success {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.present(Alert.makeServerErrorAlert(),animated: true)
                            }
                        }
                    }))
                }
                
                actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { uication in
                    if hasNote {
                        EvaluationViewModel().modifierEvaluation(id: (evaluationRep?._id)!, note: noteChoisi!) { success in
                            if success {
                                
                            } else {
                                self.present(Alert.makeServerErrorAlert(),animated: true)
                            }
                        }
                    } else {
                        EvaluationViewModel().ajouterEvaluation(idPublication: (currentPublication?._id)!, note: noteChoisi!) { success in
                            if success {
                                
                            } else {
                                self.present(Alert.makeServerErrorAlert(),animated: true)
                            }
                        }
                        
                    }
                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(actionSheet, animated: true, completion: nil)
            } else {
                self.present(Alert.makeServerErrorAlert(),animated: true)
            }
        }
    }
    
    func initializeStarButton(starButton: UIButton, isEmpty: Bool) {
        var name: String
        
        if isEmpty {
            name = "icon-star-empty"
        } else {
            name = "icon-star-filled"
        }
        
        starButton.setImage(UIImage(named: name), for: .normal)
        starButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    @objc func hoverStar1(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 1
    }
    
    @objc func hoverStar2(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 2
    }
    
    @objc func hoverStar3(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 3
    }
    
    @objc func hoverStar4(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 4
    }
    
    @objc func hoverStar5(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        
        noteChoisi = 5
    }
    
    @objc func likeButtonAction(sender: UIButton) {
        
    }
    
    @objc func showCommentsAction(sender: UIButton) {
        performSegue(withIdentifier: "commentairesSegue", sender: currentPublication)
    }
    
    @IBAction func topSwipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer ) {
        if gestureRecognizer.state == .ended {
            if ((nextPublication) != nil){
                publicationCounter += 1
                
                navigateToNextPublication()
            } else {
                //nextPublicationView.removeFromSuperview()
                print("last one")
            }
        }
    }
    
    @IBAction func downSwipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer ) {
        
        if gestureRecognizer.state == .ended {
            if ((previousPublication) != nil){
                publicationCounter -= 1
                
                navigateToPreviousPublication()
            } else {
                //previousPublicationView.removeFromSuperview()
                print("first one")
            }
        }
    }
}
