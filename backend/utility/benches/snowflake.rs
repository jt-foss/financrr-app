use criterion::{black_box, criterion_group, criterion_main, Criterion};
use utility::snowflake::SnowflakeGenerator;

pub fn next_id_benchmark(c: &mut Criterion) {
    let generator = SnowflakeGenerator::new(1, 0).unwrap();
    c.bench_function("next_id", |b| b.iter(|| black_box(generator.next_id())));
}

criterion_group!(benches, next_id_benchmark);
criterion_main!(benches);
