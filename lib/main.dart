import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'response.dart';
import 'sql.dart';
import 'package:dart_openai/openai.dart';

void main() {
  runApp(Chat());
}



class Chat extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Chatpage(),
    );
  }
}

class Chatpage extends StatefulWidget{
  @override
  State<Chatpage> createState() => _Chatpage();
}
class _Chatpage extends State<Chatpage>{
  List<String?> responses=["please include your userid at last of the text, it is a test version"];
  List<String> _usertexts=["hi"];
  TextEditingController textcontroller=TextEditingController();
  String c_id="";
  bool button_view=true;

  get_response1(String text){
    OpenAI.apiKey= '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';
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: text,
          role: OpenAIChatMessageRole.user,
        )
      ],
    );
    chatStream.listen((event) {
      setState(() {
        responses[responses.length-1]=responses[responses.length-1]!+event.choices.first.delta.content!;
      });
    },onDone: () => setState(() {
      button_view=true;
    }),onError: (e){setState((){responses[responses.length-1]="something went wrong";});});

  }
  Widget chatscreen(BuildContext context,List<String?> responses , List<String> _userinputs){
    return Container(width: double.infinity,height: MediaQuery.of(context).size.height-83, color: Colors.white,
        child:SingleChildScrollView(child:Column(
          children: [
            Container(
                padding:const EdgeInsets.symmetric(horizontal: 4),constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height-180
            ),child:Chatlist(context, responses, _userinputs)),
            Inputwidget(context),
          ],
        ),
        )
    );
  }

  Widget Chatlist(BuildContext context,List<String?> responses , List<String> _userinputs){

    return Container(
        height: MediaQuery.of(context).size.height-180,
        child:ListView.builder(
            reverse: true,
            itemCount: _userinputs.length,
            itemBuilder:(context,i){
              return
                Column(
                  children: [
                    ChatBubble(context,_userinputs.reversed.toList()[i] , Alignment.bottomRight, true),
                    const SizedBox(height: 10,),
                    // if(responses.length<_userinputs.length) ChatBubble(context, i==0?"Waiting for response":responses.reversed.toList()[i], Alignment.bottomLeft, false),
                    ChatBubble(context, responses.reversed.toList()[i], Alignment.bottomLeft, false),
                    const SizedBox(height: 10,),
                  ],
                );
            })
    );
  }

  Widget Inputwidget(BuildContext context,){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(8, 15, 8, 10),
      elevation: 3,
      child:Row(
          children:[
            Container(width:MediaQuery.of(context).size.width-64,child:TextFormField(
              maxLines: 3,
              minLines: 1,
              controller: textcontroller,
              decoration:  InputDecoration(
                  hintText: "Enter your message",
                  border: OutlineInputBorder(borderRadius:  BorderRadius.circular(10),)
              ),
            ),),
            button_view?IconButton(onPressed:() async{
              String text=textcontroller.text;
              print(text);
              setState(() {
                _usertexts.add(text);
                textcontroller.text="";
                responses.add("waiting for response from the server");
              });
              var response;
              var response1;
              if (text.toLowerCase().contains("balance")){
               response= await connecting("balance", "customer", text.substring(text.length-5));
               if (response.length!=0){
               response = "your remaining account balance is ${response}";}
               else{
                 response="error";
               }
              }
              else if (text.toLowerCase().contains("date")){
                response= await connecting("opening_date", "customer", text.substring(text.length-5));
                if (response.length!=0){
                response="your account opening date is ${response}";}
                else{
                  response="error";
                }
              }
              else if (text.toLowerCase().contains("transaction")){
                response= await connecting("last_transaction_date", "customer", text.substring(text.length-5));
                if (response.length!=0){
                response="your last transaction date is ${response}";}
                else{
                  response="error";
                }
              }
              else if (text.toLowerCase().contains("product")){
                response = await connecting("crosssell", "product", text.substring(text.length-5) );
                if (response.length!=0){
                response="products available for you are ${response}";}
                else{
                  response="error";
                }
              }
              else{
              setState(() {
                button_view=false;
              });
              get_response1(text);
              response=" ";
              }
              if(response!="error"){
                responses.add(response);
                setState(() {
                  responses.remove("waiting for response from the server");

                });


              }
              else{
                setState(() {
                  responses.add("sorry unable to respond to you, please reach us at 9999999999");
                });

              }
            }, icon: Icon(Icons.send,color: Colors.black.withOpacity(0.6),)):SizedBox.shrink()
          ]
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Builder(builder: (context)=>

        Scaffold(
          appBar: AppBar(title: Text("Chatbot",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.indigo[300],),
          body:SingleChildScrollView(child: Column(
            children: [
              chatscreen(context, responses, _usertexts)
            ],
          ),
          ),
        ));
  }
}

Widget appbar(BuildContext context) {
  return Card(elevation:6,child:Container(
    alignment: Alignment.bottomCenter,
    height: 75,width: double.infinity,
    color: Colors.indigo[300],
    child: Row(
      children: [
        // IconButton(onPressed: (){
        //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Home()));
        // }, icon: const Icon(Icons.arrow_back,color: Colors.white,)),
        const SizedBox(width: 20,),
        const Text("AI",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
        Card(elevation: 5,margin: const EdgeInsets.fromLTRB(105, 5, 10, 5),
            child:Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white),
              child: Row(children: const [
                Icon(Icons.generating_tokens_sharp,color: Colors.yellow,),
                SizedBox(width: 10,),
                Text("10",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ],),
            ))
      ],
    ) ,
  ));
}





Widget ChatBubble(BuildContext context,String? text,Alignment alignment,bool user,){
  return Align( alignment:alignment,
      child:Container(
        padding: const EdgeInsets.fromLTRB(4, 3, 4, 5),
        constraints: const BoxConstraints(maxWidth: 200,minHeight:40),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
          color: user?Colors.pinkAccent.withOpacity(0.3):Colors.blueAccent.withOpacity(0.3),),
        child: text==""?SelectableText("sorry unable to fetch",style: const TextStyle(fontStyle: FontStyle.italic,color: Colors.black54)):
        SelectableText(text!,style: const TextStyle(fontStyle: FontStyle.italic,color: Colors.black54))
        ,
      )
  );

}