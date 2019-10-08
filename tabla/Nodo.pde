class Nodo{
  String desde;
  String hasta;
  int valor;
  
  Nodo(String pDesde, String pHasta, int pValor){
    desde = pDesde;
    hasta = pHasta;
    valor = pValor;
  }
  
  String imprimir(){
    String msg = "";
    msg +="Desde: " + desde + "\n";
    msg +="Hasta: " + hasta + "\n";
    msg +="Con: " + valor + "\n\n";
    return msg;
  }
}
