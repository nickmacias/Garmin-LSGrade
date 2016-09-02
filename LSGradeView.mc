using Toybox.Application;
using Toybox.WatchUi as Ui;
//
// LS Grade - compute a least-squares fit through the last 10 (interesting)
// data points, and return its slope as the current gradient
//
class LSGradeView extends Ui.SimpleDataField {

  var saveAlt=new[10]; // record 10 prior altitude readings here
  var saveDist=new[10]; // and 10 distance readings
  var nextLoc=0; // where we'll write the *next* pieces of data

  var prevRet=0.0; // previous return value (in case we can't re-compute this time)
  var prevDist=0.0; // previous distance. "interesting" data means distance has changed
  
  var ready=false; // set when we've got full arrays
  
  function initialize() {
    SimpleDataField.initialize();

    label = "LS Grade";
    ready=false;
    nextLoc=0;
  }
  
  // compute LS gradient
  function compute(info) {
  
    if (info==null){ // does this ever happen???
      return(prevRet);
    }
    
    if ((info.altitude==null)||(info.elapsedDistance==null)){ // data not available (weird)
      return(prevRet);
    }
    
    if (info.elapsedDistance==prevDist){
      return(prevRet); // skip out quickly!
    }
    
    // we've moved!
    saveAlt[nextLoc]=info.altitude;
    saveDist[nextLoc]=info.elapsedDistance;
    ++nextLoc;
    if (nextLoc==10){
      nextLoc=0; // circular queue
      ready=true; // arrays are fully populated
    }
    
    if (!ready){
      return(prevRet); // LS data not ready...wait for more data
    }

// okay, calculate the least squares fit
// first calculate xMean and yMean

    var xSum=0.0,ySum=0.0,xMean,yMean;
    var i;
    
    for (i=0;i<10;i++){
      xSum+=saveDist[i];
      ySum+=saveAlt[i];
    }

    xMean=xSum/10.0;
    yMean=ySum/10.0;

// slope=sum[(xi-xMean)(yi-yMean)] / sum[(xi-xMean)^2]
    var top=0.0,bot=0.0;
    
    for (i=0;i<10;i++){
      top+=(saveDist[i]-xMean)*(saveAlt[i]-yMean);
      bot+=(saveDist[i]-xMean)*(saveDist[i]-xMean);
    }
    if (bot==0){
      return(prevRet);
    }
    
    prevRet=100.0*top/bot;
    return(prevRet);
  }
}

class LSGrade extends Application.AppBase
{
  function initialize()
  {
    AppBase.initialize();
  }
  
  function getInitialView()
  {
    return(new AvgGradeView());
  }
}