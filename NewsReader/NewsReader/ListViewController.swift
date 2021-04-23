//
//  ListViewController.swift
//  NewsReader
//
//  Created by 長谷川孝太 on 2021/04/21.
//

import UIKit

class ListViewController: UITableViewController, XMLParserDelegate {
    
    var parser:XMLParser!
////【疑問②】ここのItemは列挙体の型としてUIKitに元から定義されていたものなのか？　自分はenumでItemを定義していなく、Item.swift内でClassでItemを定義しただけ。
    var items = [Item]()
    var item:Item?
    var currentString = ""
    
////【確認③】次の３つの各メソッドがどのプロトコルから来ているか判断が微妙　→恐らくUITableViewControllerクラスの親クラスのUITableViewDelegateプロトコルだと判断しました。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDownload()
    }
    
    func startDownload() {
        //初期化
        self.items = []
        if let url = URL(string: "https://wired.jp/rssfeeder/") {
            //このインスタンスの型は不正なURLの場合nilを返すのでオプショナル型
            if let parser = XMLParser(contentsOf: url) {
////【確認④】下の２行消して、parser.delegate = self だけだとダメなのか？　→Viewのように１つという制限がプロトコルでついているならparserが一意に定まらずエラーになりそう
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    
    //XMLParserDelegateで宣言されているメソッド
    //必要なRSSデータの要素名のみ取り出す（要素名の開始タグが見つかるごとに呼び出される）
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //初期化
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    
    //RSSデータの要素名が見つかったら、自動的に呼び出されるメソッド
    //必要なRSSデータの内容のみ取り出す（要素名の開始タグが見つかるごとに呼び出される）
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string
    }
    
    //要素名elementNameごとに処理を分ける（要素名の終了タグが見つかると呼び出される）
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
            case "title": self.item?.title = currentString
            case "link": self.item?.link = currentString
            //ニュース記事の終わりなのでitemsにitemsのデータすべてを格納する
            case "item": self.items.append(self.item!)
            default : break
        }
    }
    
    //すべてのデータの解析が終わると実行されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        //tabelViewの内容を更新して新しく取得した内容を表示する
        //overrideした２つのメソッドが再度呼び出される
        self.tableView.reloadData()
    }
    
    //データを次の画面に写す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let item = items[indexPath.row]
//【疑問⑤(疑問①と似てる)】ここのDetailViewControllerをどこでimportしているのか知りたい。
            //ここのsegueはstoryboard上の矢印のインスタンスで、そのdestinationプロパティ＝遷移先のビューコントローラーをcontrollerに格納している
            let controller = segue.destination as! DetailViewController
            controller.title = item.title
            controller.link = item.link
        }
    }
}
