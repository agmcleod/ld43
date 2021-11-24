use std::cmp::Ordering;

use nav;

pub fn sort(center: nav::Point) -> impl Fn(&nav::Point, &nav::Point) -> Ordering {
    move |a: &nav::Point, b: &nav::Point| {
        let a_angle = (a.z - center.z).atan2(a.x - center.x);
        let b_angle = (b.z - center.z).atan2(b.x - center.x);

        b_angle.partial_cmp(&a_angle).unwrap()
    }
}

#[cfg(test)]
mod test {
    use nav;

    use super::*;

    #[test]
    fn test_sorts_counter_clockwise() {
        let mut vec = Vec::new();
        vec.push(nav::Point::new(0.0, 0.0, 32.0));
        vec.push(nav::Point::new(0.0, 0.0, 0.0));
        vec.push(nav::Point::new(32.0, 0.0, 0.0));
        vec.push(nav::Point::new(32.0, 0.0, 32.0));

        vec.sort_by(sort(nav::Point::new(16.0, 0.0, 16.0)));

        assert_eq!(vec, vec![
            nav::Point::new(0.0, 0.0, 32.0),
            nav::Point::new(32.0, 0.0, 32.0),
            nav::Point::new(32.0, 0.0, 0.0),
            nav::Point::new(0.0, 0.0, 0.0),
        ]);
    }
}