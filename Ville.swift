//
//  Ville.swift
//  appliMeteo
//
//  Created by Christopher Blard on 22/01/2021.
//

import Foundation

class Ville {
    // Création du lien basique, et information de la clé API pour accéder aux données météo
    private let lienOWMbase = "http://api.openweathermap.org/data/2.5/weather"
    private let cleAPI = "f7cbb752e14cb5cd4f084a01dc1debcc"

    // Création des variables
    public var nom: String = ""
    public var temperature: Int = 0
    public var temperatureRessentie: Int = 0
    var temps: Any? = ""
    public var descriptionTemps : String = ""
    
    // Getters
    func getNom() -> String {
        return self.nom
    }
    
    func getTemperature() -> Int {
        return self.temperature
    }
    
    func getTemps() -> String {
        return self.descriptionTemps
    }
    
    func getTemperatureRessentie() -> Int {
        return self.temperatureRessentie
    }
    
    // Setters
    func setTemperature(temperature: Int) {
        self.temperature = temperature
    }
    
    func setTemperatureRessentie(temperatureRessentie: Int) {
        self.temperatureRessentie = temperatureRessentie
    }
    
    func setDescriptionTemps(descTemps: String) {
        self.descriptionTemps = descTemps
    }
    
    
    func recupInfosMeteo(ville: String, completion: @escaping([Any])-> [Any]) {
        self.nom = ville
        
        // Création de la session URL
        let session = URLSession.shared
        
        // Création du lien complet
        let lienAPI = URL(string: "\(lienOWMbase)?APPID=\(cleAPI)&q=\(ville)")!
        
        // Création du dictionnaire à partir des données JSON du lien
        let dataTask = session.dataTask(with: lienAPI) {
            (data: Data?, response: URLResponse?, error: Error?) in
            // Si le dictionnaire ne peut pas être créé
            if let error = error {
                print("Erreur :\n\(error)")
            }
            // Sinon
            else {
                do{
                    let weather = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                
                    // Création des variables de température et de temps
                    let temperatureKelvin = weather["main"]!["temp"]!!
                    let temperatureRessentieKelvin = weather["main"]!["feels_like"]!!
                    let temps = weather["weather"]![0]
                    
                    // Conversion de Kelvin en Celsius
                    var temperatureCelsius = temperatureKelvin as! Double
                    var temperatureRessentieCelsius = temperatureRessentieKelvin as! Double
                    
                    temperatureCelsius -= 273.15
                    temperatureCelsius = round(temperatureCelsius)
                    temperatureRessentieCelsius -= 273.15
                    temperatureRessentieCelsius = round(temperatureRessentieCelsius)
                    
                    let temperature = Int(temperatureCelsius)
                    let temperatureRessentie = Int(temperatureRessentieCelsius)
                    
                    // Récupération de la description du temps (sun, clouds, ...)
                    guard let descTemps = temps as? [String: Any] else {
                        return
                    }
                    let description = descTemps["description"] as! String
                    
                    let tabRetour : [Any] = [temperature, temperatureRessentie, description]
                    completion(tabRetour)
                }
                catch let jsonError as NSError {
                // Erreur lors de la conversion des données en dictionnaire
                print("Erreur de description JSON : \(jsonError.description)")
                }
          }
        }
        dataTask.resume()
    }
}
