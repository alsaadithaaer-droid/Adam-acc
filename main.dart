import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Do not block the first Flutter frame on SQLite. If database initialization
  // fails, the UI must still open and report the error instead of showing a blank screen.
  runApp(const AdamApp());
  Future<void>.microtask(() async {
    try {
      await AppDatabase.db;
    } catch (e) {
      debugPrint('Adam database initialization error: $e');
    }
  });
}

class AdamApp extends StatelessWidget {
  const AdamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adam',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'sans',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151922),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: AdamHome(),
      ),
    );
  }
}

class AdamHome extends StatefulWidget {
  const AdamHome({super.key});
  @override
  State<AdamHome> createState() => _AdamHomeState();
}

class _AdamHomeState extends State<AdamHome> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    SalesPage(),
    PurchasesPage(),
    ProductsPage(),
    CustomersPage(),
    SuppliersPage(),
    ExpensesPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  final titles = const [
    'الرئيسية',
    'فاتورة البيع',
    'المشتريات',
    'المخزون',
    'العملاء',
    'الموردون',
    'المصروفات',
    'التقارير',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('آدم • ${titles[index]}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF101319),
      ),
      body: pages[index],
      drawer: Drawer(
        backgroundColor: const Color(0xFF101319),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B1E26), Color(0xFF0D0F13)],
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.diamond_outlined, size: 48, color: Color(0xFFD4AF37)),
                    SizedBox(height: 8),
                    Text('ADAM', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    Text('نظام المبيعات والمخزون', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < titles.length; i++)
                ListTile(
                  leading: Icon(_icons[i]),
                  title: Text(titles[i]),
                  selected: index == i,
                  onTap: () {
                    setState(() => index = i);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.shopping_cart_outlined,
    Icons.inventory_2_outlined,
    Icons.people_alt_outlined,
    Icons.local_shipping_outlined,
    Icons.payments_outlined,
    Icons.analytics_outlined,
    Icons.settings_outlined,
  ];
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  Map<String,dynamic> data = {};
  String? error;
  bool loading = true;

  @override void initState(){super.initState(); load();}

  Future<void> load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final result = await AppDatabase.dashboard();
      if (!mounted) return;
      setState(() { data = result; loading = false; });
    } catch (e) {
      debugPrint('Adam dashboard error: $e');
      if (!mounted) return;
      setState(() { loading = false; error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.warning_amber_rounded, size: 64, color: Color(0xFFD4AF37)),
          const SizedBox(height: 16),
          const Text('تم تشغيل آدم، لكن قاعدة البيانات تحتاج إلى تهيئة.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: load, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (loading) const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 8),
          const Text('لوحة التحكم', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('إدارة المبيعات والمخزون والحسابات من الهاتف، دون الحاجة للإنترنت.',
              style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              StatCard('الأصناف', '${data['products'] ?? 0}', Icons.inventory_2_outlined),
              StatCard('العملاء', '${data['customers'] ?? 0}', Icons.people_outline),
              StatCard('الموردون', '${data['suppliers'] ?? 0}', Icons.local_shipping_outlined),
              StatCard('المصروفات USD', '${data['expenses'] ?? 0}', Icons.payments_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const SectionCard(title: 'نظام آدم', child: Text(
            'العملة الأساسية: USD • دعم الليرة السورية بسعر صرف مستقل • مخزون بالقطعة والكرتونة • قاعدة بيانات محلية.',
            style: TextStyle(color: Colors.white70),
          )),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value; final IconData icon;
  const StatCard(this.title, this.value, this.icon, {super.key});
  @override Widget build(BuildContext context) => SizedBox(
    width: 175, height: 125,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: const Color(0xFFD4AF37)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white60)),
        ]),
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  final String title; final Widget child;
  const SectionCard({required this.title, required this.child, super.key});
  @override Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10), child,
      ],
    )),
  );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override State<ProductsPage> createState() => _ProductsPageState();
}
class _ProductsPageState extends State<ProductsPage> {
  List<Map<String,dynamic>> rows = [];
  @override void initState(){super.initState(); load();}
  Future<void> load() async { rows = await AppDatabase.products(); if(mounted)setState((){}); }
  Future<void> add() async {
    final name = TextEditingController(), barcode = TextEditingController(),
        qty = TextEditingController(text:'0'), cost = TextEditingController(text:'0'),
        price = TextEditingController(text:'0'), carton = TextEditingController(text:'1');
    final ok = await showDialog<bool>(context:context,builder:(_)=>FormDialog(
      title:'إضافة صنف', fields:[
        F('اسم الصنف',name),F('الباركود',barcode),F('الكمية بالقطعة',qty),
        F('تكلفة الشراء USD',cost),F('سعر البيع USD',price),F('عدد القطع بالكرتونة',carton)
      ], onSave:() async {
        await AppDatabase.addProduct({'name':name.text,'barcode':barcode.text,'qty':double.tryParse(qty.text)??0,
          'costUsd':double.tryParse(cost.text)??0,'priceUsd':double.tryParse(price.text)??0,
          'cartonSize':double.tryParse(carton.text)??1,'unit':'piece'});
      }));
    if(ok==true) load();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body: rows.isEmpty ? const Empty('لا توجد أصناف بعد') : ListView.builder(
      padding: const EdgeInsets.all(12), itemCount:rows.length,
      itemBuilder:(c,i){final r=rows[i]; return Card(child:ListTile(
        leading: const CircleAvatar(child:Icon(Icons.inventory_2_outlined)),
        title:Text(r['name']), subtitle:Text('باركود: ${r['barcode'] ?? '-'} • كمية: ${r['qty']}'),
        trailing:Text('\$${r['priceUsd']}'),
      ));}),
    floatingActionButton: FloatingActionButton.extended(onPressed:add, icon:const Icon(Icons.add), label:const Text('صنف جديد')),
  );
}

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});
  @override State<CustomersPage> createState()=>_PartyPageState<CustomerPageKind>();
}
class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});
  @override State<SuppliersPage> createState()=>_SupplierPageState();
}

enum CustomerPageKind { customer }

class _PartyPageState<T> extends State<CustomersPage> {
  List<Map<String,dynamic>> rows=[];
  @override void initState(){super.initState();load();}
  Future<void> load()async{rows=await AppDatabase.customers();if(mounted)setState((){});}
  Future<void> add()async{
    final name=TextEditingController(), phone=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(_)=>FormDialog(title:'إضافة عميل',
      fields:[F('اسم العميل',name),F('الهاتف',phone)],
      onSave:()=>AppDatabase.addCustomer({'name':name.text,'phone':phone.text,'balanceUsd':0})));
    if(ok==true)load();
  }
  @override Widget build(BuildContext c)=>Scaffold(
    body: rows.isEmpty?const Empty('لا يوجد عملاء'):ListView.builder(
      itemCount:rows.length,itemBuilder:(c,i)=>Card(child:ListTile(
        leading:const Icon(Icons.person_outline),title:Text(rows[i]['name']),
        subtitle:Text(rows[i]['phone']??''),trailing:Text('\$${rows[i]['balanceUsd']}'),
      ))),
    floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('عميل جديد')));
}

class _SupplierPageState extends State<SuppliersPage> {
  List<Map<String,dynamic>> rows=[];
  @override void initState(){super.initState();load();}
  Future<void> load()async{rows=await AppDatabase.suppliers();if(mounted)setState((){});}
  Future<void> add()async{
    final name=TextEditingController(),phone=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(_)=>FormDialog(title:'إضافة مورد',
      fields:[F('اسم المورد',name),F('الهاتف',phone)],
      onSave:()=>AppDatabase.addSupplier({'name':name.text,'phone':phone.text,'balanceUsd':0})));
    if(ok==true)load();
  }
  @override Widget build(BuildContext c)=>Scaffold(
    body: rows.isEmpty?const Empty('لا يوجد موردون'):ListView.builder(itemCount:rows.length,
      itemBuilder:(c,i)=>Card(child:ListTile(leading:const Icon(Icons.local_shipping_outlined),
        title:Text(rows[i]['name']),subtitle:Text(rows[i]['phone']??''),
        trailing:Text('\$${rows[i]['balanceUsd']}')))),
    floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('مورد جديد')));
}

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});
  @override State<ExpensesPage> createState()=>_ExpensesPageState();
}
class _ExpensesPageState extends State<ExpensesPage>{
  List<Map<String,dynamic>> rows=[];
  @override void initState(){super.initState();load();}
  Future<void> load()async{rows=await AppDatabase.expenses();if(mounted)setState((){});}
  Future<void> add()async{
    final title=TextEditingController(),amount=TextEditingController(),note=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(_)=>FormDialog(title:'إضافة مصروف',
      fields:[F('اسم المصروف',title),F('المبلغ USD',amount,keyboard:TextInputType.number),F('ملاحظة',note)],
      onSave:()=>AppDatabase.addExpense({'title':title.text,'amountUsd':double.tryParse(amount.text)??0,
        'note':note.text,'createdAt':DateTime.now().toIso8601String()})));
    if(ok==true)load();
  }
  @override Widget build(BuildContext c)=>Scaffold(
    body:rows.isEmpty?const Empty('لا توجد مصروفات'):ListView.builder(itemCount:rows.length,
      itemBuilder:(c,i)=>Card(child:ListTile(title:Text(rows[i]['title']),
        subtitle:Text(rows[i]['createdAt']),trailing:Text('\$${rows[i]['amountUsd']}')))),
    floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('مصروف جديد')));
}

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    SectionCard(title:'فاتورة بيع',child:Column(children:[
      _ActionRow(Icons.person_outline,'اختيار العميل','اختياري'),
      _ActionRow(Icons.inventory_2_outlined,'إضافة الأصناف','بالباركود أو الاسم'),
      _ActionRow(Icons.currency_exchange,'العملة','USD / ليرة سورية'),
      _ActionRow(Icons.calculate_outlined,'الربح','يحسب من تكلفة الشراء'),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:()=>showDialog(context:context,builder:(_)=>const SimpleMessage(
        title:'محرك الفاتورة', message:'واجهة الفاتورة جاهزة للربط مع حركات المخزون والدفعات.')),
        icon:const Icon(Icons.receipt_long),label:const Text('فتح فاتورة جديدة')),
    ]))
  ]);
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    SectionCard(title:'المشتريات',child:Column(children:[
      _ActionRow(Icons.local_shipping_outlined,'المورد','اختيار المورد'),
      _ActionRow(Icons.inventory_2_outlined,'الأصناف','إضافة الكميات'),
      _ActionRow(Icons.currency_exchange,'سعر الصرف','لليرة السورية'),
      _ActionRow(Icons.layers_outlined,'التكلفة','FIFO'),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:()=>showDialog(context:context,builder:(_)=>const SimpleMessage(
        title:'فاتورة شراء',message:'أضف المورد والأصناف والكميات وسيتم تحديث المخزون محلياً.')),
        icon:const Icon(Icons.add_shopping_cart),label:const Text('فاتورة شراء جديدة')),
    ]))
  ]);
}

class _ActionRow extends StatelessWidget{
  final IconData icon;final String a,b;
  const _ActionRow(this.icon,this.a,this.b);
  @override Widget build(BuildContext c)=>ListTile(leading:Icon(icon,color:const Color(0xFFD4AF37)),
    title:Text(a),subtitle:Text(b));
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('التقارير',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
    const SizedBox(height:16),
    for(final x in ['مبيعات اليوم','أرباح الفواتير','حركة المخزون','ديون العملاء','ديون الموردين','المصروفات','حركة الصندوق'])
      Card(child:ListTile(leading:const Icon(Icons.analytics_outlined),title:Text(x),
        trailing:const Icon(Icons.chevron_left)))
  ]);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage>{
  final rate=TextEditingController(text:'10000');
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('الإعدادات',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
    const SizedBox(height:16),
    TextField(controller:rate,keyboardType:TextInputType.number,decoration:const InputDecoration(
      labelText:'سعر صرف الدولار مقابل الليرة السورية',prefixIcon:Icon(Icons.currency_exchange))),
    const SizedBox(height:12),
    const Card(child:ListTile(leading:Icon(Icons.attach_money),title:Text('العملة الأساسية'),subtitle:Text('USD'))),
    const Card(child:ListTile(leading:Icon(Icons.account_balance_wallet_outlined),title:Text('الصناديق'),
      subtitle:Text('دولار + ليرة سورية + صناديق إضافية'))),
    const Card(child:ListTile(leading:Icon(Icons.backup_outlined),title:Text('النسخ الاحتياطي'),
      subtitle:Text('يمكن إضافة تصدير قاعدة البيانات لاحقاً'))),
  ]);
}

class Empty extends StatelessWidget{
  final String text; const Empty(this.text,{super.key});
  @override Widget build(BuildContext c)=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.inbox_outlined,size:60,color:Colors.white24),const SizedBox(height:12),Text(text,style:const TextStyle(color:Colors.white54))]));
}

class F {
  final String label; final TextEditingController controller; final TextInputType? keyboard;
  F(this.label,this.controller,{this.keyboard});
}
class FormDialog extends StatelessWidget{
  final String title; final List<F> fields; final Future<dynamic> Function() onSave;
  const FormDialog({required this.title,required this.fields,required this.onSave,super.key});
  @override Widget build(BuildContext c)=>AlertDialog(
    title:Text(title),content:SizedBox(width:420,child:SingleChildScrollView(
      child:Column(children:[for(final f in fields)...[
        TextField(controller:f.controller,keyboardType:f.keyboard,decoration:InputDecoration(labelText:f.label)),
        const SizedBox(height:10)
      ]])),
    ),actions:[
      TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),
      FilledButton(onPressed:()async{await onSave();if(c.mounted)Navigator.pop(c,true);},child:const Text('حفظ'))
    ]);
}

class SimpleMessage extends StatelessWidget{
  final String title,message; const SimpleMessage({required this.title,required this.message,super.key});
  @override Widget build(BuildContext c)=>AlertDialog(title:Text(title),content:Text(message),
    actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('حسناً'))]);
}
