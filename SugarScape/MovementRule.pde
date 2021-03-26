import java.util.LinkedList;
import java.util.Collections;
import java.util.HashMap;

interface MovementRule {
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle);
}

class SugarSeekingMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public SugarSeekingMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    for (Square s : neighborhood) {
      if (s.getSugar() > retval.getSugar() ||
          (s.getSugar() == retval.getSugar() && 
           g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle)
          )
         ) {
        retval = s;
      } 
    }
    return retval;
  }
}

class PollutionMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public PollutionMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    boolean bestSquareHasNoPollution = (retval.getPollution() == 0);
    for (Square s : neighborhood) {
      boolean newSquareCloser = (g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle));
      if (s.getPollution() == 0) {
        if (!bestSquareHasNoPollution || s.getSugar() > retval.getSugar() ||
            (s.getSugar() == retval.getSugar() && newSquareCloser)
           ) {
          retval = s;
        }
      }
      else if (!bestSquareHasNoPollution) { 
        float newRatio = s.getSugar()*1.0/s.getPollution();
        float curRatio = retval.getSugar()*1.0/retval.getPollution();
        if (newRatio > curRatio || (newRatio == curRatio && newSquareCloser)) {
          retval = s;
        }
      }
    }
    return retval;
  }
}

class CombatMovementRule extends SugarSeekingMovementRule {
  int alpha;
  
  public CombatMovementRule(int alpha){
    this.alpha = alpha;
  }
  
  public Square move(LinkedList<Square> neighbourhood, SugarGrid g, Square middle){
    Agent ma = middle.getAgent();
    
    for(int i = 0;i < neighbourhood.size();i++){
      Square s = neighbourhood.get(i);
      Agent sa = s.getAgent();
      if(sa != null){
        if(sa.getTribe() == ma.getTribe()){
          neighbourhood.remove(i);
          i -= 1;
        }
        else if(sa.getSugarLevel() >= ma.getSugarLevel()){
          neighbourhood.remove(i);
          i -= 1;
        }
        else{
          LinkedList<Square> otherNeighbourhood = getNeighbourhood(g,ma,sa.getSquare());
          Square o = otherNeighbourhood.get(0);
          Agent oa = o.getAgent();
          for(int x = 1;x < otherNeighbourhood.size();x++){
            o = otherNeighbourhood.get(x);
            if(o.getAgent() != null){
            if(oa == null){
              if(o.getAgent().getTribe() != ma.getTribe()){
              oa = o.getAgent();
              }
            }
            else if(oa.getSugarLevel() < o.getAgent().getSugarLevel() && o.getAgent().getTribe() != ma.getTribe()){
              oa = o.getAgent();
            }
            }
          }
          // at this point, oa is the strongest opposing tribe agent in other neighbourhood
          if(oa.getSugarLevel() >= ma.getSugarLevel()){
            neighbourhood.remove(i);
            i -= 1;
          }
        }
      }
    }
    
    HashMap<Square,Square> replacedMap = new HashMap<Square,Square>();
    for(int i =0;i < neighbourhood.size();i++){
      Square s = neighbourhood.get(i);
      if(s.getAgent() != null){
        int sugar = s.getSugar() + alpha + s.getAgent().getSugarLevel();
        int maxSugar = s.getMaxSugar() + alpha + s.getAgent().getSugarLevel();
        Square r = new Square(sugar,maxSugar,s.getX(),s.getY());
        replacedMap.put(r,s);
        neighbourhood.set(i,r);
      }
    }
    
    Square target = super.move(neighbourhood, g, middle);
    if(replacedMap.containsKey(target)){
      target = replacedMap.get(target);
      Agent casualty = target.getAgent();
      target.setAgent(null);
      ma.sugarLevel += casualty.getSugarLevel() + alpha;
      g.killAgent(casualty);
    }
    return target;
  }

  private LinkedList<Square> getNeighbourhood(SugarGrid g, Agent a, Square s) {
    int x = s.getX();
    int y = s.getY();
    int radius = a.getVision();
    LinkedList<Square> seen = g.generateVision(x,y,radius);
    return seen;
  }
  
}

class SugarSeekingMovementRuleTester {
  public void test() {
    SugarSeekingMovementRule mr = new SugarSeekingMovementRule();
    //stubbed
  }
}

class PollutionMovementRuleTester {
  public void test() {
    PollutionMovementRule mr = new PollutionMovementRule();
    //stubbed
  }
}
