let project = new Project('Quadtree Collision');
project.addAssets('Assets');
project.addSources('Sources');
if (Project.platform == 'html5') {
  project.targetOptions.html5.disableContextMenu = true;
  project.addParameter('-dce full');
}

resolve(project);
