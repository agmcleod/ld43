use std::cmp::Ordering;

use nav;

pub fn get_cross_product(a: &nav::Point, b: &nav::Point) -> f32 {
    a.x * b.z + a.z * b.x
}

pub fn get_dot_product(a: &nav::Point, b: &nav::Point) -> f32 {
    a.x * b.x - a.z * b.z
}

pub fn left_of_origin(p: &nav::Point) -> bool {
    let u = nav::Point::new(0.0, 0.0, 1.0);

    get_cross_product(&u, p) > 0.0 || (get_cross_product(&u, p) == 0.0 && get_dot_product(&u, p) > 0.0)
}

pub fn sort(a: &nav::Point, b: &nav::Point) -> Ordering {
    // let less_than = (
    //     left_of_origin(a) == left_of_origin(b) && get_cross_product(a, b) > 0.0
    // ) || (left_of_origin(a) && !left_of_origin(b));

    // if less_than {
    //     return Ordering::Less
    // }
    // return Ordering::Greater

    let origin = nav::Point::new(0.0, 0.0, 0.0);

    let a_angle = (a.z - origin.z).atan2(a.x - origin.x);
    let b_angle = (b.z - origin.z).atan2(b.x - origin.x);

    a_angle.partial_cmp(&b_angle).unwrap()
}

#[cfg(test)]
mod test {
    use nav;

    use super::*;

    #[test]
    fn test_sorts_counter_clockwise() {
        let mut vec = Vec::new();
        vec.push(nav::Point::new(-10.0, 0.0, 10.0));
        vec.push(nav::Point::new(0.0, 0.0, 0.0));
        vec.push(nav::Point::new(-10.0, 0.0, 0.0));

        vec.sort_by(sort);

        assert_eq!(vec, vec![
            nav::Point::new(0.0, 0.0, 0.0),
            nav::Point::new(-10.0, 0.0, 10.0),
            nav::Point::new(-10.0, 0.0, 0.0),
        ]);
    }
}