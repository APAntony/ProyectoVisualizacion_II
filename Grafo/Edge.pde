public class Edge{
  private Node origin;
  private Node destiny;
  private double weight;
  
  public Edge (Node origin, Node destiny,double weight){
    this.origin = origin;
    this.destiny = destiny;
    this.weight = weight;
  }
  
  public Node getOrigin(){
    return origin;
  }
  
  public Node getDestiny(){
    return destiny;
  }
  
  public double getWeight(){
    return weight;
  }
  
  public void draw(int minimum,int medium,int max){
    if (weight <= minimum){
      stroke(0,255,0);    
    } else if (weight > minimum && weight <= medium){
      stroke(255,255,0);
    } else{
      stroke(255,0,0); 
    }
    
  }
}
