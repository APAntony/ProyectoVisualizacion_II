public class ForceDirectedGraph extends Viewport implements OnValueChangeListener{

  private static final float TOTAL_KINETIC_ENERGY_DEFAULT = MAX_FLOAT;
  public static final float SPRING_CONSTANT_DEFAULT       = 0.1f;
  public static final float COULOMB_CONSTANT_DEFAULT      = 500.0f;
  public static final float DAMPING_COEFFICIENT_DEFAULT   = 0.2f;
  public static final float TIME_STEP_DEFAULT             = 2.0f;
  public static final int SPRING_LENGTH_DEFAULT             = 120;
  public static final int MINIMUM_DEFAULT = 25;
  public static final int MEDIUM_DEFAULT = 75;
  public static final int MAXIMUM_DEFAULT = 125;

  private ArrayList<Node> nodes;
  private ArrayList<Edge> edges;
  private float totalKineticEnergy;
  private float springConstant;
  private float coulombConstant;
  private float dampingCoefficient;
  private float timeStep;
  private int minimum;
  private int medium;
  private int maximum;

  private Node lockedNode;
  private Node dummyCenterNode; //for pulling the glaph to center

  public ForceDirectedGraph(){
    super();
    this.nodes = new ArrayList<Node>();
    this.edges = new ArrayList<Edge>();
    this.totalKineticEnergy = TOTAL_KINETIC_ENERGY_DEFAULT;
    this.springConstant = SPRING_CONSTANT_DEFAULT;
    this.coulombConstant = COULOMB_CONSTANT_DEFAULT;
    this.dampingCoefficient = DAMPING_COEFFICIENT_DEFAULT;
    this.timeStep = TIME_STEP_DEFAULT;
    this.minimum = MINIMUM_DEFAULT;
    this.medium = MEDIUM_DEFAULT;
    this.maximum = MAXIMUM_DEFAULT;

    this.lockedNode = null;
    this.dummyCenterNode = new Node("", 1.0f);
  }

  public void add(Node node){
    this.nodes.add(node);
  }
  public void addEdge(String id1, String id2, float weight){
    Node node1 = this.getNodeWith(id1);
    Node node2 = this.getNodeWith(id2);
    node1.add(node2, SPRING_LENGTH_DEFAULT);
    node2.add(node1, SPRING_LENGTH_DEFAULT);
    Edge edge = new Edge(node1,node2,weight);
    edges.add(edge);
  }
  private Node getNodeWith(String id){
    Node node = null;
    for(int i = 0; i < this.nodes.size(); i++){
      Node target = this.nodes.get(i);
      if(target.getID().equals(id)){
        node = target;
        break;
      }
    }
    return node;
  }

  public void initializeNodeLocations(){
    float maxMass = 4.0f;
    
    float nodeSizeRatio;
    if(this.getWidth() < this.getHeight())
      nodeSizeRatio = this.getWidth() / (maxMass * 5.0f); //ad-hoc
    else
      nodeSizeRatio = this.getHeight() / (maxMass * 5.0f); //ad-hoc
    float offset = nodeSizeRatio * maxMass;
    float minXBound = this.getX() + offset;
    float maxXBound = this.getX() + this.getWidth() - offset;
    float minYBound = this.getY() + offset;
    float maxYBound = this.getY() + this.getHeight() - offset;
    for(int i = 0; i < this.nodes.size(); i++){
      Node node = this.nodes.get(i);
      float x = random(minXBound, maxXBound);
      float y = random(minYBound, maxYBound);
      float d = node.getMass() * nodeSizeRatio;
      node.set(x, y, d);
    }
  }

  public void draw(){
    this.totalKineticEnergy = this.calculateTotalKineticEnergy();

    strokeWeight(1.5f);
    this.drawEdges();
    for(int i = 0; i < this.nodes.size(); i++)
      this.nodes.get(i).draw();
  }

  private void drawEdges(){
    stroke(51, 51, 255);
    for(int i = 0; i < this.nodes.size(); i++){
      Node node1 = this.nodes.get(i);
      for(int j = 0; j < node1.getSizeOfAdjacents(); j++){
        Node node2 = node1.getAdjacentAt(j);
        for (int d = 0; d<edges.size();d++){
          if (edges.get(d).getOrigin() == node1 &&edges.get(d).getDestiny() == node2){
            edges.get(d).draw(minimum,medium,maximum);
            break;
          }
        }
        line(node1.getX(), node1.getY(), node2.getX(), node2.getY());
        
      }
    }
  }

  private float calculateTotalKineticEnergy(){ //ToDo:check the calculation in terms of Math...
    for(int i = 0; i < this.nodes.size(); i++){
      Node target = this.nodes.get(i);
      if(target == this.lockedNode)
        continue;

      float forceX = 0.0f;
      float forceY = 0.0f;
      for(int j = 0; j < this.nodes.size(); j++){ //Coulomb's law
        Node node = this.nodes.get(j);
        if(node != target){
          float dx = target.getX() - node.getX();
          float dy = target.getY() - node.getY();
          float distance = sqrt(dx * dx + dy * dy);
          float xUnit = dx / distance;
          float yUnit = dy / distance;

          float coulombForceX = this.coulombConstant * (target.getMass() * node.getMass()) / pow(distance, 2.0f) * xUnit;
          float coulombForceY = this.coulombConstant * (target.getMass() * node.getMass()) / pow(distance, 2.0f) * yUnit;

          forceX += coulombForceX;
          forceY += coulombForceY;
        }
      }

      for(int j = 0; j < target.getSizeOfAdjacents(); j++){ //Hooke's law
        Node node = target.getAdjacentAt(j);
        float springLength = target.getNaturalSpringLengthAt(j);
        float dx = target.getX() - node.getX();
        float dy = target.getY() - node.getY();
        float distance = sqrt(dx * dx + dy * dy);
        float xUnit = dx / distance;
        float yUnit = dy / distance;

        float d = distance - springLength;

        float springForceX = -1 * this.springConstant * d * xUnit;
        float springForceY = -1 * this.springConstant * d * yUnit;

        forceX += springForceX;
        forceY += springForceY;
      }

      target.setForceToApply(forceX, forceY);
    }

    float totalKineticEnergy = 0.0f;
    for(int i = 0; i < this.nodes.size(); i++){
      Node target = this.nodes.get(i);
      if(target == this.lockedNode)
        continue;

      float forceX = target.getForceX();
      float forceY = target.getForceY();

      float accelerationX = forceX / target.getMass();
      float accelerationY = forceY / target.getMass();

      float velocityX = (target.getVelocityX() + this.timeStep * accelerationX) * this.dampingCoefficient;
      float velocityY = (target.getVelocityY() + this.timeStep * accelerationY) * this.dampingCoefficient;

      float x = target.getX() + this.timeStep * target.getVelocityX() + accelerationX * pow(this.timeStep, 2.0f) / 2.0f;
      float y = target.getY() + this.timeStep * target.getVelocityY() + accelerationY * pow(this.timeStep, 2.0f) / 2.0f;

      float radius = target.getDiameter() / 2.0f; //for boundary check
      if(x < this.getX() + radius)
        x = this.getX() + radius;
      else if(x > this.getX() + this.getWidth() - radius)
        x =  this.getX() + this.getWidth() - radius;
      if(y < this.getY() + radius)
        y = this.getY() + radius;
      else if(y > this.getY() + this.getHeight() - radius)
        y =  this.getX() + this.getHeight() - radius;

      target.set(x, y);
      target.setVelocities(velocityX, velocityY);
      target.setForceToApply(0.0f, 0.0f);

      totalKineticEnergy += target.getMass() * sqrt(velocityX * velocityX + velocityY * velocityY) / 2.0f;
    }
    return totalKineticEnergy;
  }

  public void onMouseMovedAt(int x, int y){
    for(int i = 0; i < this.nodes.size(); i++){
      Node node = this.nodes.get(i);
      if(node.isIntersectingWith(x, y))
        node.highlight();
      else
        node.dehighlight();
    }
  }
  public void onMousePressedAt(int x, int y){
    for(int i = 0; i < this.nodes.size(); i++){
      Node node = this.nodes.get(i);
      if(node.isIntersectingWith(x, y)){
        this.lockedNode = node;
        this.lockedNode.setVelocities(0.0f, 0.0f);
        break;
      }
    }
  }
  public void onMouseDraggedTo(int x, int y){
    if(this.lockedNode != null){
      float radius = this.lockedNode.getDiameter() / 2.0f; //for boundary check
      if(x < this.getX() + radius)
        x = (int)(this.getX() + radius);
      else if(x > this.getX() + this.getWidth() - radius)
        x =  (int)(this.getX() + this.getWidth() - radius);
      if(y < this.getY() + radius)
        y = (int)(this.getY() + radius);
      else if(y > this.getY() + this.getHeight() - radius)
        y =  (int)(this.getX() + this.getHeight() - radius);

      this.lockedNode.set(x, y);
      this.lockedNode.setVelocities(0.0f, 0.0f);
    }
  }
  public void onMouseReleased(){
    this.lockedNode = null;
  }
  
  public void onMinimumChangedTo(int value){
    this.minimum = value;
  }
  
  public void onMediumChangedTo(int value){
    this.medium = value;
  }
  
  public void onMaximumChangedTo(int value){
    this.maximum = value;
  }

}
