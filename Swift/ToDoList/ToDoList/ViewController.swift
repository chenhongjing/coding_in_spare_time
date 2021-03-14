//
//  ViewController.swift
//  ToDoList
//
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //.xcdatamodeld的Entity那边得选 Manual/None,否则这里会报错
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
            let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        view.addSubview(tableView)
        //不要忘了添加getAllItems()，这样重新加载时，所有之前的数据才会显示在上面
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        //在右上角添加一个+号，点击后执行的动作是selector里面的didTapAdd函数
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd(){
        //一个弹出消息框
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        //加入一个文本编辑框
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            //guard->语法糖
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        //加入一个actionSheet(具体是什么运行一下就知道了)
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            //一个弹出消息框
            let alert = UIAlertController(title: "Edit Item", message: "Enter your item", preferredStyle: .alert)
            //加入一个文本编辑框
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else{
                    return
                }
                self?.updateItem(item: item, newName:newName)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self]_ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
        
    }
    
    
    func getAllItems(){
        do{
            models = try context.fetch(ToDoListItem.fetchRequest())
            //在main thread中完成
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        catch{
            //error
        }
    }
    
    func createItem(name: String){
        //新建事项
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.date = Date()
        
        do{
            try context.save()
            
            //重新加载所有数据
            getAllItems()
        }
        catch{
            //error
        }
    }
    
    func deleteItem(item: ToDoListItem){
        context.delete(item)
        
        do{
            try context.save()
            //一定要记得刷新
            getAllItems()
        }
        catch{
            //error
        }
    }

    func updateItem(item: ToDoListItem, newName: String){
        item.name = newName
        
        do{
            try context.save()
            //一定要记得刷新
            getAllItems()
        }
        catch{
            //error
        }
    }
}

