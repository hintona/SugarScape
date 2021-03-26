import java.util.Map;
import java.util.Random;

class FertilityRule {
  Map<Character,Integer[]> childbearingOnset;
  Map<Character, Integer[]> climactericOnset;
  // both onset maps will store sex, min age, then max age
  ArrayDictionary<Agent, Integer[]> agentDict;
  // agentDict will store Agent, start of fertility period, end of fertility period, sugar level
  
  public FertilityRule(Map<Character, Integer[]> childbearingOnset, Map<Character,Integer[]> climactericOnset) {
    this.childbearingOnset = childbearingOnset;
    this.climactericOnset = climactericOnset;
    this.agentDict = new ArrayDictionary<Agent, Integer[]>();
  }
  
  public boolean isFertile(Agent a) {
    if(a == null || !a.isAlive()) { 
      if(a != null){
        if(a.getSquare() !=null) a.getSquare().setAgent(null);
        a.setSNNode(null);
        a = null;
        return false;
      }
      if(agentDict.containsKey(a)) agentDict.remove(a);
      return false;
      }
    else if(agentDict.containsKey(a)) {
      if(a.getSugarLevel() >= agentDict.get(a)[2]){
        if(agentDict.get(a)[0] <= a.getAge() && a.getAge() <= agentDict.get(a)[1]) return true;
        else return false;
      }
      else return false;
    }
    else {
      Integer[] agentNums = new Integer[3];
      agentNums[0] = getRand(childbearingOnset.get(a.getSex())[0],childbearingOnset.get(a.getSex())[1]);
      agentNums[1] = getRand(climactericOnset.get(a.getSex())[0],climactericOnset.get(a.getSex())[1]);
      agentNums[2] = a.getSugarLevel();
      agentDict.put(a,agentNums);
      if(agentNums[0] <= a.getAge() && a.getAge() <= agentNums[2]) return true;
      else return false;
    }
  }
  
  public boolean canBreed(Agent a, Agent b, LinkedList<Square> local) {
    if(isFertile(a) && isFertile(b)){
      if(local.contains(b.getSquare())){
        while(local.size() != 0){
          Square s = local.remove();
          if(s.getAgent() == null) return true;
        }
        return false;
      }
      else return false;
    }
    else return false;
  }
  
  public Agent breed(Agent a, Agent b, LinkedList<Square> alocal, LinkedList<Square> blocal) {
    if(!canBreed(a,b,alocal)) return null;
    else if(canBreed(a,b,alocal)){ 
      int metabolism = pick(a,b).getMetabolism();
      int vision = pick(a,b).getVision();
      Agent child = new Agent(metabolism, vision, 0, a.getMovementRule());
      if(agentDict.get(a) == null) return null;
      if(agentDict.get(b) == null) return null;
      a.gift(child,agentDict.get(a)[2]/2); 
      b.gift(child,agentDict.get(b)[2]/2);
      isFertile(child);
      LinkedList<Square> area = new LinkedList<Square>();
      for(Square s : alocal){
        area.add(s);
      }
      for(Square s : blocal){
        area.add(s);
      }
      child.setSquare(area.get(getRand(0,area.size()-1)));
      child.nurture(a,b);
      return child;
    }
    else return null;
  }
  
  private int getRand(int min, int max) {
    Random r = new Random();
    int num = min + r.nextInt(max+1 - min);
    return num;
  }
  
  private Agent pick(Agent a, Agent b){
    Random r = new Random();
    int num = r.nextInt(2);
    if(num == 0) return a;
    else return b;
  }
  
}
