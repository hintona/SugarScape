import java.lang.Math;
import java.util.Random;

class Agent implements Comparable<Agent> {
  public static final int NOLIFESPAN = -999;
  public static final int MAXWIDTH = 1000; // for use in compareTo()
  private int metabolism;
  private int vision;
  private int sugarLevel;
  private MovementRule movementRule;
  private char sex;
  private int age;
  private int lifespan;
  private Square square;
  private int[] fillColor;
  private SocialNetworkNode snNode;
  private boolean[] culture;
  
  /* initializes a new Agent with the specified values for its 
  *  metabolism, vision, stored sugar, and movement rule.
  *
  */
  public Agent(int metabolism, int vision, int initialSugar, MovementRule m, char sex) {
    this.metabolism = metabolism;
    this.vision = vision;
    this.sugarLevel = initialSugar;
    this.movementRule = m;
    this.sex = sex;
    age = 0;
    lifespan = NOLIFESPAN;
    square = null;
    int[] tmp = {0, 0, 0};
    fillColor = tmp;
    snNode = null;
    assert(sex == 'X' || sex == 'Y'); 
    this.culture = genCulture();
  }
  
  public Agent(int metabolism, int vision, int initialSugar, MovementRule m) {
    this.metabolism = metabolism;
    this.vision = vision;
    this.sugarLevel = initialSugar;
    this.movementRule = m;
    this.sex = randsex();
    age = 0;
    lifespan = NOLIFESPAN;
    square = null;
    int[] tmp = {0, 0, 0};
    fillColor = tmp;
    snNode = null;
    this.culture = genCulture();
  }
  
  private boolean[] genCulture(){
    Random r = new Random();
    boolean[] culture = new boolean[11];
    for(int i = 0; i < 11;i++){
      culture[i] = r.nextBoolean();
    }
    return culture;
  }

  public void influence(Agent other) {
    Random r = new Random();
    int num = r.nextInt(11);
    if(this.culture[num] != other.culture[num]){
      other.culture[num] = this.culture[num];
    }
  }

  public void nurture(Agent parent1, Agent parent2) {
    Random r = new Random();
    for(int i = 0;i < 11;i++){
      if(r.nextBoolean()){
        this.culture[i] = parent1.culture[i];
      }
      else{
        this.culture[i] = parent2.culture[i];
      }
    }
  }

  public boolean getTribe() {
    int counter = 0;
    for(int i = 0;i < 11;i++){
      if(culture[i]) counter++;
    }
    if(counter >=6) return true;
    else return false;
  }
  
  private char randsex(){
    Random r = new Random();
    boolean sex = r.nextBoolean();
    if(sex) return 'X';
    else return 'Y';
  }
  
  public char getSex(){
    return sex;
  }
  
  public void gift(Agent other, int amount){
    assert(this.sugarLevel >= amount);
    this.sugarLevel -= amount;
    other.sugarLevel += amount;
  }
  
  /* returns the amount of food the agent needs to eat each turn to survive. 
  *
  */
  public int getMetabolism() {
    return metabolism; 
  } 
  
  /* returns the agent's vision radius.
  *
  */
  public int getVision() {
    return vision; 
  } 
  
  /* returns the amount of stored sugar the agent has right now.
  *
  */
  public int getSugarLevel() {
    return sugarLevel; 
  } 
  
  /* returns the Agent's movement rule.
  *
  */
  public MovementRule getMovementRule() {
    return movementRule; 
  } 
  
  /* returns the Agent's age.
  *
  */
  public int getAge() {
    return age; 
  } 
  
  /* sets the Agent's age.
  *
  */
  public void setAge(int howOld) {
    assert(howOld >= 0);
    this.age = howOld; 
  } 
  
  /* returns the Agent's lifespan.
  *
  */
  public int getLifespan() {
    return lifespan; 
  } 
  
  /* sets the Agent's lifespan.
  *
  */
  public void setLifespan(int span) {
    assert(span >= 0);
    this.lifespan = span; 
  } 
  
  /* returns the Square occupied by the Agent.
  *
  */
  public Square getSquare() {
    return square; 
  } 
  
  /* sets the the Square occupied by the Agent.
  *
  */
  public void setSquare(Square s) {
    this.square = s; 
  } 
  
  /* sets the fill color to display this agent
   */
  public void setFillColor(int r, int g, int b) {
    int[] tmp = {r, g, b};
    fillColor = tmp;
  }
  
  /* gets the SocialNetworkNode
   */
  public SocialNetworkNode getSNNode() {
    return snNode;
  }
  
  /* sets the SocialNetworkNode
   */
  public void setSNNode(SocialNetworkNode node) {
    snNode = node;
  }
  
  /* Moves the agent from source to destination. 
  *  If the destination is already occupied, the program should crash with an assertion error
  *  instead, unless the destination is the same as the source.
  *
  */
  public void move(Square source, Square destination) {
    // make sure this agent occupies the source
    if(this != source.getAgent());
    else if (!destination.equals(source)) { 
      assert(destination.getAgent() == null);
      source.setAgent(null);
      destination.setAgent(this);
    }
  } 
  
  /* Reduces the agent's stored sugar level by its metabolic rate, to a minimum value of 0.
  *
  */
  public void step() {
    sugarLevel = Math.max(0, sugarLevel - metabolism); 
    age += 1;
  } 
  
  /* returns true if the agent's stored sugar level is greater than 0, false otherwise. 
  * 
  */
  public boolean isAlive() {
    return (sugarLevel > 0);
  } 
  
  /* The agent eats all the sugar at its Square. 
  *  The agent's sugar level is increased by that amount, and 
  *  the amount of sugar on the square is set to 0.
  *
  */
  public void eat() {
    sugarLevel += getSquare().getSugar();
    getSquare().setSugar(0);
  } 
  
  /* Two agents are equal only if they're the same agent, 
  *  not just if they have the same properties.
  */
  public boolean equals(Agent other) {
    return this == other;
  }
  
  public void display(int x, int y, int scale) {
    fill(fillColor[0], fillColor[1], fillColor[2]);
    ellipse(x, y, 3.0*scale/4, 3.0*scale/4);
  }
  
  /* compares the raster index x + width*y of this Agent's square to that of the other Agent's square
   *  - width is chosen to be something larger than the likely width of a SugarGrid to avoid ties.
   *
   */
  public int compareTo(Agent other) {
    Integer myVal = new Integer(square.getX() + Agent.MAXWIDTH*square.getX());
    if(other == null) return 0;
  //  assert(other != null);
 //   assert(other.getSquare() != null);
    if(other.getSquare() == null) return 0;
    Integer otherVal = new Integer(other.square.getX() + Agent.MAXWIDTH*other.square.getX());
    return myVal.compareTo(otherVal);
  }
}

class AgentTester {
  
  public void test() {
    
    // test constructor, accessors
    int metabolism = 3;
    int vision = 2;
    int initialSugar = 4;
    MovementRule m = null;
    Agent a = new Agent(metabolism, vision, initialSugar, m);
    assert(a.isAlive());
    assert(a.getMetabolism() == 3);
    assert(a.getVision() == 2);
    assert(a.getSugarLevel() == 4);
    assert(a.getMovementRule() == null);
    
    // movement
    Square s1 = new Square(5, 9, 10, 10);
    Square s2 = new Square(5, 9, 12, 12);
    s1.setAgent(a);
    a.move(s1, s2);
    assert(s2.getAgent().equals(a));
    
    // eat
    a.eat();
    assert(a.getSugarLevel() == 9);
    
    // test get/set MovementRule
    
    // step
    a.step();
    assert(a.getSugarLevel() == 6);
    a.step();
    a.step();
    a.step();
    assert(a.getSugarLevel() == 0);
    assert(!a.isAlive());
  }
}
