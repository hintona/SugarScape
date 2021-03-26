SugarGrid myGrid;
int sgWidth;
Graph numGraph;
Graph ageAvgGraph;
Graph wealthGraph;
SocialNetwork socialNetwork;
Random rand;


void setup() { 
  /* Testing */
  (new SquareTester()).test();
  (new AgentTester()).test();
  (new SugarGridTester()).test();  
  (new GrowbackRuleTester()).test();
  (new StackTester()).test();
  (new QueueTester()).test();
  (new ReplacementRuleTester()).test();
  (new SeasonalGrowbackRuleTester()).test();

  size(1400, 1000);
  sgWidth = 1400;
  background(128);

  int numAgents = 20;
  int minMetabolism = 3;
  int maxMetabolism = 6;
  int minVision = 3;
  int maxVision = 6;
  int minInitialSugar = 5;
  int maxInitialSugar = 10;
  MovementRule mr1 = new SugarSeekingMovementRule();
  MovementRule mr2 = new CombatMovementRule(3);
  
  AgentFactory af1 = new AgentFactory(minMetabolism, maxMetabolism, minVision, maxVision, 
    minInitialSugar, maxInitialSugar, mr1);
  AgentFactory af2 = new AgentFactory(minMetabolism, maxMetabolism, minVision, maxVision, 
    minInitialSugar, maxInitialSugar, mr2);

  int alpha = 2;
  int beta = 1;
  int gamma = 1;
  int equator = 1;
  int numSquares = 4; 
  HashMap<Character,Integer[]> childOn = new HashMap<Character,Integer[]>();
  HashMap<Character, Integer[]> climacOn = new HashMap<Character,Integer[]>();
  Integer[] child = {12,15};
  Integer[] climac = {40,50};
  childOn.put('X',child);
  childOn.put('Y',child);
  climacOn.put('X',climac);
  climacOn.put('Y',climac);
  SeasonalGrowbackRule sgr = new SeasonalGrowbackRule(alpha, beta, gamma, equator, numSquares);
  FertilityRule fr = new FertilityRule(childOn,climacOn);
  ReplacementRule rr = new ReplacementRule(40,100,af1);
  

  myGrid = new SugarGrid(50, 50, 20, sgr,fr,rr);
  myGrid.addSugarBlob(15, 15, 2, 8);
  myGrid.addSugarBlob(35, 35, 2, 8);
  for (int i = 0; i < numAgents; i++) {
    Agent a = af1.makeAgent();
    Agent b = af2.makeAgent();
    myGrid.addAgentAtRandom(a);
    myGrid.addAgentAtRandom(b);
  }

  numGraph = new NumberOfAgentsTimeSeriesGraph(sgWidth-350, 50, 300, 150);
  ageAvgGraph = new AverageAgentAgeTimeSeriesGraph(sgWidth-350, 250, 300, 150, 1000);
  wealthGraph = new SortedAgentWealthGraph(sgWidth-350, 450, 300, 150);

  rand = new Random();

  frameRate(5);
  print("Press t to show tribes, and s to show sex of agents.");
}

void draw() {  
  numGraph.update(myGrid);
  ageAvgGraph.update(myGrid);
  wealthGraph.update(myGrid);
  myGrid.update();
  socialNetwork = new SocialNetwork(myGrid);
  // Display a random path in the social network
  ArrayList<Agent> agents = myGrid.getAgents();
  Agent randomAgent1 = agents.get(rand.nextInt(agents.size()));
  Agent randomAgent2 = agents.get(rand.nextInt(agents.size()));
  List<Agent> path = socialNetwork.bacon(randomAgent1, randomAgent2);
  int[] blue = {0, 0, 255};
  int[] diff = {0, 255, -255}; // destination: green
  int[] magenta = {255, 0, 255}; // in case of collision

  /*Square s1 = randomAgent1.getSquare();
  println("Blue agent: ", s1.getX() + ", " + s1.getY());
  Square s2 = randomAgent2.getSquare();
  println("Green agent: ", s2.getX() + ", " + s2.getY());
  if (randomAgent1 == randomAgent2) {
    randomAgent2.setFillColor(magenta[0], magenta[1], magenta[2]);
  } else {
    randomAgent1.setFillColor(blue[0], blue[1], blue[2]);
    if (path != null) {
      path.remove(0);
      int steps = path.size();
      float step = 1.0;
      for (Agent a : path) {
        a.setFillColor(blue[0] + (int)(step*diff[0]/steps), 
          blue[1] + (int)(step*diff[1]/steps), 
          blue[2] + (int)(step*diff[2]/steps));
        step += 1.0;
      }
    } else {
      randomAgent2.setFillColor(blue[0]+diff[0], blue[1]+diff[1], blue[2]+diff[2]);
    }
  }*/
  myGrid.display();
  for (Agent a : agents) {
    if(keyPressed){
      if(key == 's'){
        if(a.getSex() == 'X') a.setFillColor(255,0,255);
        else a.setFillColor(0,0,255);
      }
      if(key == 't'){
        if(a.getTribe()) a.setFillColor(0,255,-255);
        else a.setFillColor(255,0,0);
      }
     }
    }
}
