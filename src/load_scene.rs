use gdnative::{GodotString, Instance, NativeClass, PackedScene, ResourceLoader};

#[derive(Debug, Clone, PartialEq)]
pub enum ManageErrs {
    CouldNotMakeInstanceNode,
    CouldNotMakeInstanceNativeClass,
    RootClassNotSpatial(String),
}

pub fn load_scene(path: &str) -> Option<PackedScene> {
    let scene = ResourceLoader::godot_singleton().load(
        GodotString::from_str(path), // could also use path.into() here
        GodotString::from_str("PackedScene"),
        false,
    );

    scene.and_then(|s| s.cast::<PackedScene>())
}

/// Root here is needs to be the same type (or a parent type) of the node that you put in the child
///   scene as the root. For instance Spatial is used for this example.
pub unsafe fn instance_scene<C>(scene: &PackedScene) -> Result<Instance<C>, ManageErrs>
where
    C: gdnative::NativeClass,
    C::Base: Clone,
{
    let inst_option = scene.instance(0); // 0 - GEN_EDIT_STATE_DISABLED

    if let Some(instance) = inst_option {
        if let Some(instance_node) = instance.cast::<C::Base>() {
            if let Some(instance) = Instance::<C>::try_from_unsafe_base(instance_node) {
                Ok(instance)
            } else {
                Err(ManageErrs::CouldNotMakeInstanceNativeClass)
            }
        } else {
            Err(ManageErrs::RootClassNotSpatial(
                instance.get_name().to_string(),
            ))
        }
    } else {
        Err(ManageErrs::CouldNotMakeInstanceNode)
    }
}
