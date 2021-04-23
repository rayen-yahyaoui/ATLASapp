import 'package:mongo_dart/mongo_dart.dart';
import 'package:sevr/sevr.dart';

void start() async {
  //Log into database
  final db= await Db.create(
    'mongodb+srv://cbuser:cbpass@cluster0.dvzsu.mongodb.net/dbuser?retryWrites=true&w=majority');
  await db.open();
  
  
  final coll = db.collection('contacts');
  

  //create server
  const port= 8000 ;
  final serv = Sevr();

  final corsPaths = ['/', '/:id'];
  for (var route in corsPaths) {
    serv.options(route, [
      (req, res) {
        setCors(req, res);
        return res.status(200);
      }
    ]);
  }


  serv.get('/', [
    setCors,
    (ServRequest req, ServResponse res)async{
      final contacts = await coll.find().toList();
      return res.status(200).json({'contacts':contacts});
    }
  ]);
  serv.post('/',[
    setCors,
    (ServRequest req, ServResponse res)async{
    await coll.save(req.body);
    return res.json(
      await coll.findOne(where.eq('name', req.body['name'])),
  );
  }
  ]);

  // have connections
  serv.listen(port, callback : (){
      print('server listening on port : $port');
  });

}

void setCors(ServRequest req, ServResponse res) {
  res.response.headers.add('Access-Control-Allow-Origin', '*');
  res.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, DELETE');
  res.response.headers
      .add('Access-Control-Allow-Headers', 'Origin, Content-Type');
}
