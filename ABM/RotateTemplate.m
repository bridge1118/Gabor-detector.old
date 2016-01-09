minx = min(selectedx(1:numElement)); maxx = max(selectedx(1:numElement)); centerx = floor((minx+maxx)/2.); 
miny = min(selectedy(1:numElement)); maxy = max(selectedy(1:numElement)); centery = floor((miny+maxy)/2.); 
for (i = 1 : numElement)
    selectedx(i) = selectedx(i) - centerx; 
    selectedy(i) = selectedy(i) - centery; 
end

for (flip = 0 : flipOrNot)
    if (flip > 0)
      for (i = 1 : numElement)
          selectedy(i) = -selectedy(i);
          if (selectedOrient(i)>0)
             selectedOrient(i) = numOrient - selectedOrient(i); 
          end
      end
    end
 for (rot = -rotateShiftLimit : rotateShiftLimit)
   theta = pi*rot/numOrient; 
   sintheta = sin(theta); costheta = cos(theta); 
   r = (rot+rotateShiftLimit+1) + (rotateShiftLimit*2+1)*flip; 
   if (rot == 0)
        for (i = 1 : numElement)
           allSelectedx(r, i) = selectedx(i); 
           allSelectedy(r, i) = selectedy(i); 
           allSelectedOrient(r, i) = selectedOrient(i); 
        end
   else 
        for (i = 1 : numElement)
           allSelectedx(r, i) = selectedx(i)*costheta + selectedy(i)*sintheta; 
           allSelectedy(r, i) = -selectedx(i)*sintheta + selectedy(i)*costheta; 
           allSelectedOrient(r, i) = selectedOrient(i) - rot; 
           if (allSelectedOrient(r, i) >= numOrient)
               allSelectedOrient(r, i) = allSelectedOrient(r, i) - numOrient; 
           end
           if (allSelectedOrient(r, i) < 0)
               allSelectedOrient(r, i) = allSelectedOrient(r, i) + numOrient; 
           end
        end
   end
 end
end