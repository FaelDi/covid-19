//
//  FirstViewController.swift
//  covid-19
//
//  Created by Rafael Dias ferreira on 24/03/20.
//  Copyright © 2020 Rafael Dias ferreira. All rights reserved.
//

import UIKit
import Alamofire


class FirstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    

    @IBOutlet weak var tableview: UITableView!
    
    
    struct Docs:Codable {
        var docs: [Case];
        var published_in: String?;
        var updated_at: String?;
    }
    
    struct Case:Codable {
        
        var cases: Int?;
        var city_cod: Int?;
        var city_name: String?;
        var count: Int?;
        var date : String?;
        var state: String?;
        var state_cod: Int?;
        
    }
    
    var objects = [Case]();
    var estados :[String] = [];
    var objetosPorEstado: [String:[Case]] = [:];
    var casosPorEstado: [String:Int] = [:];
    
    func calcCasos() {
        for elm in objetosPorEstado {
            for strc in elm.value {
                if let cidade = strc.city_name{
                    casosPorEstado[cidade] = 0;
                    if let casos = strc.cases {
                        casosPorEstado[cidade]! += casos;
                        debugPrint(casosPorEstado[cidade]!);
                    }
                }
            }
        }
        
    }
    
    func setRegioes(){
        for elm in objects {
            if let cases = elm.cases {
                if let city_cod = elm.city_cod{
                    if let city_name = elm.city_name{
                        if let count = elm.count {
                            if let date = elm.date {
                                if let state = elm.state {
                                    if let state_cod = elm.state_cod{
                                        var dado: Case = Case();
                                        dado.cases = cases;
                                        dado.city_cod = city_cod;
                                        dado.city_name = city_name;
                                        dado.count = count;
                                        dado.date = date;
                                        dado.state = state;
                                        dado.state_cod = state_cod;
                                        
                                        if !estados.contains(dado.state!) {
                                            estados.append(dado.state!);
                                            objetosPorEstado[state] = []
                                            self.tableview.reloadData();
                                        }
                                        
                                        
                                        
                                        objetosPorEstado[state]?.append(dado);
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //debugPrint(objetosPorEstado);
    }
    
    override func viewDidLoad() {
        self.tableview.dataSource = self;
        self.tableview.delegate = self;
        super.viewDidLoad()
        request();
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableview.reloadData();
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var x: [Case] = [];
        if( objetosPorEstado.count > 0){
            x = self.objetosPorEstado[estados[section]]!;
            //debugPrint(x);
        }else{
            return 0;
        }

        return x.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return estados.count;
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return estados[section];
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "covid19Cell",for: indexPath)


        if let estado = self.objetosPorEstado[estados[indexPath.section]] {
            if let nome = estado[indexPath.row].city_name{
                cell.textLabel?.text = "\(casosPorEstado[nome]!)";
            }
        }
        
        return cell
    }


        func request () {
            AF.request("https://especiais.g1.globo.com/bemestar/coronavirus/mapa-coronavirus/data/brazil-cases.json").response { response in
            
                if let jsonData = response.data {
                    let informacao = try! JSONDecoder().decode(Docs.self, from: jsonData)
                    self.objects = informacao.docs;
                    self.setRegioes();
                    self.calcCasos();
                }
            }

        }

}



