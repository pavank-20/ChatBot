import "package:mysql1/mysql1.dart";

connecting(keyword,table,id) async{
  List final_result=[];
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: "database12.c1blhehaszsm.ap-south-1.rds.amazonaws.com",
    port: 3306,
    user: "root",
    password: "Ravikiran",
    db: "pavandb"
  ));
  try{
    print(id);
    var result=await conn.query("select ${keyword} from ${table} where cust_id=?",[id]);
    conn.close();
    for (var rows in result){
      return rows[0].toString();
    }
  }on MySqlException catch(e){return "error";}on Exception catch(e){
    return "error";
  }
}




