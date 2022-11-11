use libsql_bindgen::*;

#[no_mangle]
pub fn encrypt(data: String, key: String) -> String {
    use magic_crypt::MagicCryptTrait;
    let mc = magic_crypt::new_magic_crypt!(key, 256);

    mc.encrypt_str_to_base64(data)
}
