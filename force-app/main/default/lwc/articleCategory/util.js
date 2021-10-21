
export function getAllChildrenNames(item){
  
    return [getName(item), ...getChildrenNames(item)].flatMap(x => x)
}

function getChildrenNames(item){
    
    const names = item.children.map(x => getName(x))
  
    if(item.children){
      return [...names, ...item.children.map(x => getChildrenNames(x).flatMap(x => x))]
    }
    
    return names
}

function getName(item){
    return item.name
}