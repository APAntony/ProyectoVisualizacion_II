final int CANVAS_WIDTH_DEFAULT  = 1000;
final int CANVAS_HEIGHT_DEFAULT = 700;

final String DATA_FILE_PATH = "PC2-Datos.csv";

ForceDirectedGraph forceDirectedGraph;
ControlPanel controlPanel;

public void settings() {
  size(1000, 700);
}

void setup(){
  int canvasWidth = CANVAS_WIDTH_DEFAULT;
  int canvasHeight = CANVAS_HEIGHT_DEFAULT;
  settings();
  forceDirectedGraph = createForceDirectedGraphFrom(DATA_FILE_PATH);
  forceDirectedGraph.set(0.0f, 0.0f, (float)canvasWidth * 0.8f, (float)canvasHeight);
  forceDirectedGraph.initializeNodeLocations();
  controlPanel = new ControlPanel(forceDirectedGraph, forceDirectedGraph.getX() + forceDirectedGraph.getWidth(), 0.0f, (float)canvasWidth * 0.2f, (float)canvasHeight);
}

void draw(){
  background(255);
  forceDirectedGraph.draw();
  controlPanel.draw();
}

void mouseMoved(){
  if(forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseMovedAt(mouseX, mouseY);
}
void mousePressed(){
  if(forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMousePressedAt(mouseX, mouseY);
  else if(controlPanel.isIntersectingWith(mouseX, mouseY))
    controlPanel.onMousePressedAt(mouseX, mouseY);
}
void mouseDragged(){
  if(forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseDraggedTo(mouseX, mouseY);
  else if(controlPanel.isIntersectingWith(mouseX, mouseY))
    controlPanel.onMouseDraggedTo(mouseX, mouseY);
}
void mouseReleased(){
  if(forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseReleased();
}

ForceDirectedGraph createForceDirectedGraphFrom(String dataFilePath){
  ForceDirectedGraph forceDirectedGraph = new ForceDirectedGraph();
  
  String[] lines = loadStrings(dataFilePath);
  
  String nodoString = lines[0];

  String[] nodos = splitTokens(nodoString,";");

  int numberOfNodes = nodos.length;
  float mass = 1.0;
  for(int i = 0; i < numberOfNodes; i++){
    String id =nodos[i];
    forceDirectedGraph.add(new Node(id, mass));
  }

  for(int i = 1; i < lines.length; i++){
    String[] edges = splitTokens(lines[i],";");
    forceDirectedGraph.addEdge(edges[0],edges[1],float(edges[2]));
  }
  return forceDirectedGraph;
}
