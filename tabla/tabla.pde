Table table;
String[] countries = new String[39];
Nodo[] nodos;

void loadCountries(){
  TableRow row = table.getRow(0);
  for(int i=0; i<39; i++){
    countries[i] = row.getString(i);
    //println(row.getString(i));
  }
}

void loadNodos(){
  nodos = new Nodo[table.getRowCount()-1];
  for(int i=1; i<table.getRowCount(); i++){
    TableRow row = table.getRow(i);
    Nodo n = new Nodo(row.getString(0), row.getString(1), row.getInt(2));
    nodos[i-1] = n;
    //println(nodos[i-1].imprimir());
  }
}

//Function to search the position of a determinate country
int searchCountry(String[] countries, String objetive){
  for(int i=0; i<countries.length; i++){
    if(countries[i] == objetive){
      return i;
    }
  }
  
  return -1;
}

void setup() {
  size(900,1000);
  //table = loadTable("../data/PC2-Datos.csv");
  //loadCountries();
  //loadNodos();
}

void draw() {
  for(int j=0; j<39; j++){
    for(int i=0; i<39; i++){
      fill(255);
      rect(i*25, j*25, 25, 25);
    }
  }
  
  for(int j=0; j<39; j++){
    for(int i=0; i<39; i++){
      
      
      if(j==0){
        textSize(10);
        fill(0);
        text("Coco"/*countries[i]*/, j*25, i*25);       
      }
      
      if(i==0){
        textSize(10);
        fill(0);
        text("Coco"/*countries[i]*/, j*25, i*25);
      }
      
      if(j==0 && i==0){
        textSize(10);
        fill(0);
        text("LOLO"/*countries[i]*/, j*25, i*25);
      }
    }
  }
}
