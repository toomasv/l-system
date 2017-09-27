# l-system
Playground for l-system

Changing a model and navigating away from it does not forget the changes, but changes are not saved. Previous state can be restored by `Reload`-ing.

* `Save` saves all models together.
* `Save as ...` adds new model to the list and saves all. (Currently the model, on which new one is based, is changed also.)
* `Save image` saves only active image.
* `Delete` deletes current model from list but doesn't save the changed list until `Save` (or `Save as ...`) is clicked.
* `Reload` reloads all models from file in last saved state.
