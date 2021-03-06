
pcPlayerGoalsData <- reactive({
  
  # set minimum goals 
  minGoals <- Place %>% 
    mutate(goals=(SixYd+PenArea+LongRange)) %>% 
    group_by(PLAYERID,name) %>% 
    summarise(tot=sum(goals)) %>% 
    filter(tot>=input$pcPlGoals) %>% 
    .$PLAYERID
  
print(glimpse(Place))
  
  if (input$pcPlGoalsCat=="Long Range") {
    
  df <- Place %>% 
    filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
    mutate(goals=(SixYd+PenArea+LongRange)) %>% 
    group_by(PLAYERID,name) %>% 
    summarise(tot=sum(goals),lr=sum(LongRange),pc=round(100*lr/tot)) %>% 
    ungroup() %>% 
    arrange(desc(pc))  
  } else if(input$pcPlGoalsCat=="Pen Area") {
    df <- Place %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(SixYd+PenArea+LongRange)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(PenArea),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="6yd Box") {
    df <- Place %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(SixYd+PenArea+LongRange)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(SixYd),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Open Play") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Open),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Corner") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Corner),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Throw In") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Throw),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  }else if(input$pcPlGoalsCat=="Indirect FK") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(IFK),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  }else if(input$pcPlGoalsCat=="Penalty") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Pen),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  }else if(input$pcPlGoalsCat=="Direct FK") {
    df <- Play %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Open+Corner+Throw+IFK+DFK+Pen)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(DFK),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Right Foot") {
    df <- Method %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Right+Left+Head)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Right),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Left Foot") {
    df <- Method %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Right+Left+Head)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Left),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  } else if(input$pcPlGoalsCat=="Header") {
    df <- Method %>% 
      filter(PLAYERID %in% minGoals&PLAYERID!="OWNGOAL") %>% 
      mutate(goals=(Right+Left+Head)) %>% 
      group_by(PLAYERID,name) %>% 
      summarise(tot=sum(goals),lr=sum(Head),pc=round(100*lr/tot)) %>% 
      ungroup() %>% 
      arrange(desc(pc))
  }
  # jitter so points are distinguishable
  df$jitpc <- jitter(df$pc, amount=0.2)
  df$jittot <- jitter(df$tot, amount=0.2)
  
  info=list(df=df,category=input$pcPlGoalsCat)
  return(info)
})

output$pcPlayerGoals <- renderPlotly({
  

  
  df <- pcPlayerGoalsData()$df
  
  print(glimpse(df))
  
df %>% 
  plot_ly() %>% 
  add_markers(x = ~jittot, y = ~jitpc,  hoverinfo = "text",
        text = ~ paste(name,
                     "<br>Category: ",lr,
                     "<br>Total: ",tot,
                     "<br>PerCent: ",pc,"%")) %>%
  layout(hovermode = "closest",
         title=paste0(pcPlayerGoalsData()$category," as % of Premier League Goals"),
         xaxis=list(title="Total Goals"),
         yaxis=list(title="% By category"
         )
  )  %>% 
  config(displayModeBar = F,showLink = F)

})