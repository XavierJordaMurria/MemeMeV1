//
//  MemeModel.swift
//  MemeMeV1
//
//  Created by Xavier Jorda Murria on 13/10/2015.
//
//
import UIKit
import Foundation

class MemeModel
{
    struct Meme
    {
        var topText: String
        var bottomText: String
        var image: UIImage? = nil
        var memeImage: UIImage? = nil
    }
    
    private var memeStruct: Meme
    
    init(topText: String, bottomText: String, image: UIImage, memeImage: UIImage)
    {
        memeStruct = Meme.init(topText: topText, bottomText: bottomText, image: image, memeImage: memeImage)
    }
    
    func getMemeStruct() -> Meme
    {
        return memeStruct
    }
    
}