mod spell;
pub use self::spell::*;

pub enum SPELL_STATUS_TYPE {
  ARCANE,
  FIRE,
  FROST,
}

pub enum SPELL_TYPE {
  BALL,
  WAVE,
  SHEILD,
}
