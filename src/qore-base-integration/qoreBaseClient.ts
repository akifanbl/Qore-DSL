import axios from 'axios';
import env from '../env';

export class QoreBaseClient {
    host: string;
    adminSecret: string;

    constructor(host: string = "http://localhost:8080", adminSecret: string = "admin-secret") {
        this.host = host;
        this.adminSecret = adminSecret;
    }

    async postMigrate (payload:any){
        const endpoint = "/v1/migrate"

        try {
            const { data } = await axios.post(
              `${this.host}${endpoint}`,
              payload,
              {
                headers: {
                  'Content-Type': 'application/json',
                  Accept: 'application/json',
                  'x-qore-engine-admin-secret': this.adminSecret
                },
              },
            );
            console.log(JSON.stringify(data, null, 4));
            return data;
          } catch (error) {
            if (axios.isAxiosError(error)) {
              console.log('error message: ', error.message);
              return error.message;
            } else {
              console.log('unexpected error: ', error);
              return 'An unexpected error occurred';
            }
          }
    }
}

export const ddlModelSample = "I am a very smart model database generating bot. If you ask me to build a model for the app you describe, I'll give an answer based on that description. If the description of your application is still not clear, I will respond with \"please provide a more detailed description of your application!\"\n\nQ : create a model for a book selling application where the user is the author of the book\nA :\nmodel user {\n  external_id str [pk]\n  password str [nullable : false]\n  age int [default: 20 nullable : true]\n  profile_pict file [default: {filename: \"avatar\" size: 124.3 mime: \".jpg\"}]\n}\n\nmodel books {\n  id int [pk]\n  title str\n  author user ManyToOne OnDelete:RESTRICT\n}\n\nQ : create a model for a restaurant management app\nA :\nmodel customer {\n  external_id str [pk]\n  name str [nullable : false]\n}\n\nmodel foods{\n  name str [unique:true]\n  stock int [default:0]\n}\n\nmodel order {\n  id int [pk]\n  customer customer ManyToOne OnDelete:SETNULL\n  food customer ManyToOne OnDelete:SETNULL\n  quantity int [nullable:false]\n}\n"
