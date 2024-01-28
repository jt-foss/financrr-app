use sea_orm::{ConnectionTrait, DatabaseConnection, EntityTrait, Schema};

use crate::prelude::{Account, Currency, Transaction, User, UserAccount};

pub async fn load_schema(db: &DatabaseConnection) {
	create_table_if_not_exist(Currency, db).await;
	create_table_if_not_exist(User, db).await;
	create_table_if_not_exist(Account, db).await;
	create_table_if_not_exist(UserAccount, db).await;
	create_table_if_not_exist(Transaction, db).await;
}

pub async fn create_table_if_not_exist<E, C>(entity: E, db: &C)
where
	E: EntityTrait,
	C: ConnectionTrait,
{
	let builder = db.get_database_backend();
	let schema = Schema::new(builder);
	let mut table = schema.create_table_from_entity(entity);
	table.if_not_exists();
	db.execute(builder.build(&table))
		.await
		.unwrap_or_else(|_| panic!("Could not create table: {}!", entity.table_name()));
}
