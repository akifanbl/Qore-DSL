import { Configuration, OpenAIApi } from "openai";
import env from "../env";

export class OpenAIClient {
  config: Configuration;
  openaiAPI: OpenAIApi;

  constructor() {
    this.config = new Configuration({
      apiKey: env.OPENAI_API_KEY,
    });
    this.openaiAPI = new OpenAIApi(this.config);
  }

  async createCompletion(promptSample: string, question: string): Promise<string> {
    const prompt = `${promptSample}\nQ : ${question}\nA : `
    const response = await this.openaiAPI.createCompletion({
      model: "text-davinci-003",
      prompt,
      temperature: 0.2,
      max_tokens: 2000,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    });
    console.log({ response })
    return response.data.choices[0].text || '';
  }
}

export const ddlModelSample = `\
I am a very smart database model generator bot. This model will be used to built a backend of an application using relational database by another tools, called Qore. If the description of your application is still not clear, I will respond with "please provide a more detailed description of your application!"
Here are some model rules:
1. No need to include the following poins on our generated model since they are did exist in Qore system:
* id column or primary key as those are default for every table
* external_id, email, phone, password, role columns in 'users' table, because 'users' table is a default table in Qore with those columns as default columns
2. I generate model which is a domain specific language that will be parsed to create table, column with column type and definitions, relation, index, role and permissions, insight, and view.
3. Supported column types include : bigint, boolean, datetime, date, file, float, int, json, linestring, multiFile, password, point, polygon, raw, richtext, select, string, and timestamp.
4. Supported column definitions : enums:[val1 val2 val3], unique:boolean, nullable:boolean, default:boolean
5. Supported relation types include : OneToMany, ManyToOne, ManyToMany, OneToOne
6. Supported relation definitions : OnUpdate:CASCADE/RESTRICT/SET NULL ,OnDelete:CASCADE/RESTRICT/SET NULL , nullable:boolean
7. Supported index types include: btree, hash, gist, gin, spgist, brin. indexes would be considered for use for columns that are frequently requested to be read or sorted but tend to perform write operations infrequently
8. Another index attributes is unique:boolean, and condition:"formula"
9. Permission can be given to a table or a filtered row in a table using filter formula

Q: Create a model for an online marketplace that connects people who want to rent out their homes with people who are looking for accommodations in specific locales
A:
table users{
  full_name string
  birth_date date
  gender string
  address string
  city string
  state string
  zip_code string
  profile_picture file [extensions:".png, .jpg, .svg"]
}
table home_owners{
  bio string
}
table home_owner_rating {
  score int [enums:[1 2 3 4 5]]
  description string
  home_owner home_owners ManyToOne
}
table rooms_rating {
  score int [enums:[1 2 3 4 5]]
  description string
  room rooms ManyToOne
}
table homes{
  name string
  owner users ManyToOne
  address string
  city string
  state string
  zip_code string
  pictures multiFile
  rating int [enums:[1 2 3 4 5]]
}
table rooms{
  home homes ManyToOne
  name string
  type string
  description string
  price int
  pictures multiFile
  availability boolean
}
table bookings{
  home homes ManyToOne OnDelete:SET NULL
  renter users ManyToOne OnDelete:SET NULL
  start_date date
  end_date date
  status string [enums:["waiting for payment" "paid"]]
}
role home_owner{
  select insert update delete [homes["owner.external_id == user.id"] rooms["owner.external_id == user.id"]]
  select update delete [users["external_id == user.id"]]
  select [bookings["home.owner.external_id == user.id"]]
}
role renter{
  select insert update [bookings["renter.external_id == user.id"]]
  select update delete [users["external_id == user.id"]]
}
index homes_index{
  table homes
  columns [name address city state]
  type btree
}
index rooms_index{
  table rooms
  columns [name type price]
  type btree
}
`
